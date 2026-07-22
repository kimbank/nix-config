#!/usr/bin/env bash
set -euo pipefail

# pnpm 11 starts with a new global/v11 layout, so its normal global update
# command cannot see packages that only exist in pnpm 10's layout. Add missing
# tracked packages once, then let pnpm's native updater handle the v11 globals.
migration_packages=(
  "@biomejs/biome"
  "@openai/codex"
  "bash-language-server"
  "eas-cli"
)

installed_packages="$(pnpm list --global --depth=0 --json)"

for package in "${migration_packages[@]}"; do
  if jq --exit-status --arg package "$package" \
    '((.[0].dependencies // {}) | has($package))' \
    <<<"$installed_packages" >/dev/null; then
    continue
  fi

  pnpm add --global "${package}@latest"
done

# Refresh OpenCode explicitly before the general update so any new release can
# run its required package-scoped lifecycle build. The following native update
# then covers every package in pnpm 11's global directory, including packages
# that are not part of the one-time migration list above.
pnpm add --global --allow-build=opencode-ai opencode-ai@latest
pnpm update --global --latest
