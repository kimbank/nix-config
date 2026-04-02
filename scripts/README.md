# Local Setup Scripts

`scripts/` contains repo-local helper scripts that are meant to be run by a person on their own machine. These scripts handle local setup, bootstrap, and one-off maintenance tasks that should stay outside the Nix module layer.

This directory is organized by task, not by file type. Prefer a task-specific subdirectory when a script needs companion files such as `.env.example`, fixtures, or helper notes.

Current conventions:

- Put each task under its own subdirectory when it has setup inputs or is likely to grow.
- Keep tracked templates such as `.env.example` next to the script they belong to.
- Keep real local secrets out of git. For task directories, prefer `.env` as the local copy name.
- Add a task-local `README.md` only when the subdirectory grows enough that the top-level index is no longer sufficient.

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
