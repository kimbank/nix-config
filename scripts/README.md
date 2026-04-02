# Local Setup Scripts

Use `scripts/` for repo-local helper scripts, and prefer a task-specific subdirectory when a script family is likely to grow.

Current layout:

- `github-local-auth/setup-github-local-auth.sh`: bootstraps local-only GitHub account setup from 1Password without editing the tracked Nix modules.

It creates or updates:

- `~/Github/*/.envrc` for bucket-level `GH_TOKEN` loading with `direnv`
- `~/.ssh/*.pub` files from 1Password SSH key items
- `~/.config/git/includes/*.inc` per-bucket Git include files
- a managed include block in `~/.gitconfig`

Run it after 1Password app integration is enabled and your vault items exist:

```sh
cp ./scripts/github-local-auth/.env.example ./scripts/github-local-auth/.env
# edit ./scripts/github-local-auth/.env
bash ./scripts/github-local-auth/setup-github-local-auth.sh
```

If you want each bucket's `.envrc` to contain a plaintext `GH_TOKEN` instead of an `op://...` reference, run:

```sh
bash ./scripts/github-local-auth/setup-github-local-auth.sh --danger
```

`--danger` reads the token from 1Password at script runtime and writes it directly into `~/Github/*/.envrc`, so use it only when you explicitly want local plaintext secrets on disk.

The actual `scripts/github-local-auth/.env` file is ignored by git. Use `--env-file /path/to/file` if you want to keep the config elsewhere.

For convenience during the move to `scripts/github-local-auth/`, the script also falls back to legacy local paths `scripts/github-local-auth/github-local-auth.env` and `scripts/github-local-auth.env` if the new default env file does not exist.
