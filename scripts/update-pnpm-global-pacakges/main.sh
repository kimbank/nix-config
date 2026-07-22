#!/usr/bin/env bash
set -euo pipefail

# pnpm 11 starts with a new global/v11 layout, so `update -g` cannot see
# packages installed by pnpm 10. `add -g <package>@latest` is intentionally
# idempotent: it installs missing packages during migration and updates them on
# later runs. Install packages separately so pnpm 11 keeps each CLI isolated.
packages=(
  "@biomejs/biome"
  "@openai/codex"
  "bash-language-server"
  "eas-cli"
  "opencode-ai"
)

for package in "${packages[@]}"; do
  install_args=(--global)

  # OpenCode needs its install script to materialize bundled CLI assets. Keep
  # the exception package-scoped instead of allowing every dependency build.
  case "$package" in
    opencode-ai)
      install_args+=(--allow-build=opencode-ai)
      ;;
  esac

  pnpm add "${install_args[@]}" "${package}@latest"
done
