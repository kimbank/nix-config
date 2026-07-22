#!/usr/bin/env bash
set -euo pipefail

# Global agent CLIs are intentionally updated to the registry's current latest
# tag. Keep this override scoped to this script so normal project installs keep
# pnpm 11's default 24-hour minimum release age.
export pnpm_config_minimum_release_age=0

# pnpm 11 starts with a new global/v11 layout, so its normal global update
# command cannot see packages that only exist in pnpm 10's layout. Add missing
# tracked packages once, then let pnpm's native updater handle the v11 globals.
migration_packages=(
  "@biomejs/biome"
  "@openai/codex"
  "bash-language-server"
  "eas-cli"
)
explicit_build_packages=("opencode-ai")
removed_legacy_packages=("openclaw")

has_global_package() {
  local package="$1"
  local package_list="$2"

  jq --exit-status --arg package "$package" \
    'any(.[]; ((.dependencies // {}) | has($package)))' \
    <<<"$package_list" >/dev/null
}

is_removed_legacy_package() {
  local package="$1"
  local removed_package

  for removed_package in "${removed_legacy_packages[@]}"; do
    [[ "$package" == "$removed_package" ]] && return 0
  done

  return 1
}

cleanup_pnpm10_globals() {
  local expected_pnpm_home="$HOME/Library/pnpm"
  local legacy_global_dir="$expected_pnpm_home/global/5"
  local legacy_manifest="$legacy_global_dir/package.json"

  [[ -f "$legacy_manifest" ]] || return 0

  if [[ "${PNPM_HOME:-}" != "$expected_pnpm_home" ]]; then
    printf 'Skipping pnpm 10 cleanup: unexpected PNPM_HOME=%s\n' "${PNPM_HOME:-<unset>}" >&2
    return 0
  fi

  local current_packages
  current_packages="$(pnpm list --global --depth=0 --json)"

  local package
  for package in "${migration_packages[@]}" "${explicit_build_packages[@]}"; do
    if ! has_global_package "$package" "$current_packages"; then
      printf 'Keeping pnpm 10 globals: %s is not installed in pnpm 11 yet.\n' "$package" >&2
      return 0
    fi
  done

  local unexpected_packages=()
  while IFS= read -r package; do
    if has_global_package "$package" "$current_packages" || is_removed_legacy_package "$package"; then
      continue
    fi
    unexpected_packages+=("$package")
  done < <(jq -r '.dependencies // {} | keys[]' "$legacy_manifest")

  if (( ${#unexpected_packages[@]} > 0 )); then
    printf 'Keeping pnpm 10 globals; migrate or remove these packages first:' >&2
    printf ' %s' "${unexpected_packages[@]}" >&2
    printf '\n' >&2
    return 0
  fi

  # Remove only top-level shims that point into the verified legacy layout.
  # Other files under PNPM_HOME are left untouched.
  local shim
  for shim in "$expected_pnpm_home"/*; do
    [[ -f "$shim" ]] || continue
    if grep -Fq 'global/5/' "$shim" 2>/dev/null; then
      rm -f -- "$shim"
    fi
  done

  rm -rf -- "$legacy_global_dir"
  printf 'Removed migrated pnpm 10 global layout: %s\n' "$legacy_global_dir"
}

installed_packages="$(pnpm list --global --depth=0 --json)"

for package in "${migration_packages[@]}"; do
  if has_global_package "$package" "$installed_packages"; then
    continue
  fi

  # The tracked CLIs other than OpenCode do not need dependency lifecycle
  # scripts. In particular, EAS CLI pulls in Bunyan's optional, legacy
  # dtrace-provider addon, which pnpm would otherwise ask to build.
  pnpm add --global --ignore-scripts "${package}@latest"
done

# Refresh OpenCode explicitly before the general update so any new release can
# run its required package-scoped lifecycle build. The following native update
# then covers every package in pnpm 11's global directory, including packages
# that are not part of the one-time migration list above.
pnpm add --global --allow-build=opencode-ai opencode-ai@latest
pnpm update --global --latest --ignore-scripts
cleanup_pnpm10_globals
