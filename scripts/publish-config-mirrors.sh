#!/usr/bin/env bash
set -euo pipefail

script_name="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

branch="main"
ref="HEAD"
dry_run=0

usage() {
  cat <<EOF
Usage: ${script_name} [--branch BRANCH] [--ref GIT_REF] [--dry-run] [all|config]

Publishes the repo-managed config tree to a standalone mirror repository by
splitting subtree history from this repository and force-pushing the result.

Targets:
  all       publish every configured mirror target
  config    publish modules/shared/config -> kimbank/.config

Environment overrides:
  PUBLISH_GITHUB_TOKEN      optional token injected into https://github.com/... URLs
  CONFIG_MIRROR_URL         override the .config mirror repo URL

Notes:
  - This is a mirror-style publish. The target branch is force-updated.
  - Only committed history at the selected ref is published.
EOF
}

target_prefix() {
  case "$1" in
    config)
      printf '%s\n' 'modules/shared/config'
      ;;
    *)
      return 1
      ;;
  esac
}

target_repo_url() {
  case "$1" in
    config)
      printf '%s\n' "${CONFIG_MIRROR_URL:-git@github.com:kimbank/.config.git}"
      ;;
    *)
      return 1
      ;;
  esac
}

authenticated_url() {
  local url="$1"
  local token="${PUBLISH_GITHUB_TOKEN:-}"

  if [[ -n "$token" && "$url" == https://github.com/* ]]; then
    printf 'https://x-access-token:%s@%s\n' "$token" "${url#https://}"
    return 0
  fi

  if [[ -n "$token" && "$url" == git@github.com:* ]]; then
    printf 'https://x-access-token:%s@github.com/%s\n' "$token" "${url#git@github.com:}"
    return 0
  fi

  printf '%s\n' "$url"
}

publish_target() {
  local target="$1"
  local prefix
  local repo_url
  local push_url
  local split_commit

  prefix="$(target_prefix "$target")" || {
    echo "Unknown target: ${target}" >&2
    exit 1
  }
  repo_url="$(target_repo_url "$target")"
  push_url="$(authenticated_url "$repo_url")"

  if [[ ! -d "$prefix" ]]; then
    echo "Target path does not exist: ${prefix}" >&2
    exit 1
  fi

  printf 'Splitting %s from %s (%s)\n' "$target" "$ref" "$prefix"
  split_commit="$(git subtree split --prefix="$prefix" "$ref")"

  printf 'Publishing %s to %s (%s -> %s)\n' "$target" "$repo_url" "$split_commit" "$branch"
  if [[ $dry_run -eq 1 ]]; then
    printf 'Dry run: git push --force %s %s:refs/heads/%s\n' "$repo_url" "$split_commit" "$branch"
    return 0
  fi

  git push --force "$push_url" "${split_commit}:refs/heads/${branch}"
}

targets=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      branch="$2"
      shift 2
      ;;
    --ref)
      ref="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    all)
      targets=("config")
      shift
      ;;
    config)
      targets+=("$1")
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ${#targets[@]} -eq 0 ]]; then
  targets=("config")
fi

cd "$repo_root"
git rev-parse --verify "${ref}^{commit}" >/dev/null

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree is dirty; only committed history at ${ref} will be published." >&2
fi

for target in "${targets[@]}"; do
  publish_target "$target"
done
