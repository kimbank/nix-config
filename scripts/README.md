# Local Setup Scripts

`scripts/` contains repo-local helper scripts that are meant to be run by a person on their own machine. These scripts handle local setup, bootstrap, and one-off maintenance tasks that should stay outside the Nix module layer.

This directory is organized by task, not by file type. Prefer a task-specific subdirectory when a script needs companion files such as `.env.example`, fixtures, or helper notes.

Current conventions:

- Put each task under its own subdirectory when it has setup inputs or is likely to grow.
- Keep tracked templates such as `.env.example` next to the script they belong to.
- Keep real local secrets out of git. For task directories, prefer `.env` as the local copy name.
- Add a task-local `README.md` only when the subdirectory grows enough that the top-level index is no longer sufficient.

## adb-shutter-sound-off

`adb-shutter-sound-off/` contains a small local helper to disable Samsung's forced camera shutter sound setting over ADB.

Files:

- `adb-shutter-sound-off/adb-shutter-sound-off.sh`: waits for an authorized device, writes the setting, then stops the local ADB server on exit

```sh
bash ./scripts/adb-shutter-sound-off/adb-shutter-sound-off.sh
```

If the phone shows an `Allow USB debugging` prompt, approve it and the script will continue automatically.

## github-local-auth

`github-local-auth/` contains the local GitHub bucket authentication bootstrap flow that reads from 1Password and writes machine-local Git and SSH setup.

Files:

- `github-local-auth/setup-github-local-auth.sh`: main entrypoint
- `github-local-auth/.env.example`: tracked template for local config
- `github-local-auth/.env`: ignored local copy used at runtime

This task creates or updates:

- `~/Github/*/.envrc` for bucket-level `GH_TOKEN` loading with `direnv`
- `~/.ssh/*.pub` files from 1Password SSH key items
- `~/.config/git/includes/*.inc` per-bucket Git include files
- a managed include block in `~/.gitconfig`

```sh
cp ./scripts/github-local-auth/.env.example ./scripts/github-local-auth/.env
# edit ./scripts/github-local-auth/.env
bash ./scripts/github-local-auth/setup-github-local-auth.sh
```

If you want each bucket's `.envrc` to contain a plaintext `GH_TOKEN` instead of an `op://...` reference, run `bash ./scripts/github-local-auth/setup-github-local-auth.sh --danger`.

Use `--env-file /path/to/file` if you want to keep the local config somewhere else.

For convenience during the move to `scripts/github-local-auth/`, the script also falls back to legacy local paths `scripts/github-local-auth/github-local-auth.env` and `scripts/github-local-auth.env` if the new default env file does not exist.

## update-pnpm-global-pacakges

`update-pnpm-global-pacakges/` contains the repeatable install/update list for CLI packages intentionally managed in pnpm's global directory.

Files:

- `update-pnpm-global-pacakges/main.sh`: migrates tracked pnpm 10 globals when needed, refreshes OpenCode with its lifecycle-build exception, and runs pnpm's native global updater

```sh
bash ./scripts/update-pnpm-global-pacakges/main.sh
```

The script currently tracks Biome, Codex, Bash Language Server, EAS CLI, and OpenCode. It sets `pnpm_config_minimum_release_age=0` only for its own process so these explicitly requested global agent CLIs follow the registry's current `latest` tags; ordinary project installs retain pnpm 11's default 24-hour protection. pnpm 11 uses a new `global/v11` layout and stores shims under `$PNPM_HOME/bin`, so packages still missing from v11 are installed once with `add`. After migration, `pnpm update --global --latest --ignore-scripts` updates every package in the v11 global directory, including manually added packages that are not in the migration list.

General installs and updates disable lifecycle scripts. This intentionally declines optional native addons such as EAS CLI's `@expo/logger -> bunyan -> dtrace-provider` chain, which is only for DTrace-based log instrumentation and is not needed for normal EAS use. OpenCode is the exception: it needs its install script to materialize bundled CLI assets, so the updater refreshes it explicitly with pnpm 11's package-scoped `--allow-build=opencode-ai` exception before the general update. When another existing pnpm 10 global CLI needs to migrate, add its package name to the script instead of leaving an ad hoc command in a package module. If it needs a lifecycle build, add a narrow package exception; do not enable all dependency builds globally just to bypass pnpm 11's safety check.

After a successful update, the script verifies that every tracked package exists in pnpm 11. It removes the pnpm 10 `global/5` directory and only those top-level `$PNPM_HOME` shims that point into it when every legacy package is either present in v11 or explicitly listed for removal. `openclaw` is intentionally removed during this cleanup. Any unknown legacy package makes cleanup stop without deleting the old layout.

The nixpkgs Node 24 build currently used on Apple Silicon Darwin has a known file-descriptor tracking bug that can abort pnpm 11 after installation. `modules/shared/packages.nix` temporarily runs only the Nix-provided pnpm executable with Node 22; the adjacent `TODO` and upstream issue links define when to remove that workaround. This does not change the mise-managed Node version used by installed CLI applications.
