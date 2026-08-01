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

## ssh-tresor-from-1password

`ssh-tresor-from-1password/` contains an interactive helper that reads a secret
from the 1Password CLI and encrypts it for a selected SSH-agent key. It always
uses ssh-tresor's armored text format and writes a new destination with mode
`0600`.

```sh
./scripts/ssh-tresor-from-1password/main.sh
```

The helper prompts for an `op://` reference and accepts the surrounding single
or double quotes included by some copy flows. It then lists the keys currently
exposed by the SSH agent and prompts for a `SHA256:...` fingerprint.

For output, enter only a file name to write it under
`~/.config/secrets/tresor`; a missing `.tresor` suffix is added automatically.
Press Enter at the file-name prompt to provide an absolute path instead. The
helper encrypts to a temporary file in the destination directory and only
replaces the final path after the pipeline succeeds.

The prompts can also be supplied as options:

```sh
./scripts/ssh-tresor-from-1password/main.sh \
  --op-reference 'op://vault/item/field' \
  --fingerprint 'SHA256:REPLACE_ME' \
  --name 'github-token'
```

Use `--output '/absolute/path/to/secret.tresor'` instead of `--name` when the
destination should live outside `~/.config/secrets/tresor`. The two options are
mutually exclusive.

Use `--force` only when an existing destination should be replaced without an
interactive confirmation. The secret itself is streamed from `op read` to
`ssh-tresor`; it is not accepted as an argument or stored in a shell variable.

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
