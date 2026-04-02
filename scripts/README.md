# Local Setup Scripts

`setup-github-local-auth.sh` bootstraps local-only GitHub account setup from 1Password without editing the tracked Nix modules.

It creates or updates:

- `~/Github/*/.envrc` for bucket-level `GH_TOKEN` loading with `direnv`
- `~/.ssh/*.pub` files from 1Password SSH key items
- `~/.config/git/includes/*.inc` per-bucket Git include files
- a managed include block in `~/.gitconfig`

Run it after 1Password app integration is enabled and your vault items exist:

```sh
cp ./scripts/github-local-auth.env.example ./scripts/github-local-auth.env
# edit ./scripts/github-local-auth.env
bash ./scripts/setup-github-local-auth.sh
```

If you want each bucket's `.envrc` to contain a plaintext `GH_TOKEN` instead of an `op://...` reference, run:

```sh
bash ./scripts/setup-github-local-auth.sh --danger
```

`--danger` reads the token from 1Password at script runtime and writes it directly into `~/Github/*/.envrc`, so use it only when you explicitly want local plaintext secrets on disk.

The actual `scripts/github-local-auth.env` file is ignored by git. Use `--env-file /path/to/file` if you want to keep the config elsewhere.

## Config Mirror Publishing

`publish-config-mirrors.sh` exports the repo-managed config tree to a standalone mirror repository.

Current target:

- `modules/shared/config` -> `kimbank/.config`

Example:

```sh
export PUBLISH_GITHUB_TOKEN=YOUR_TOKEN
bash ./scripts/publish-config-mirrors.sh config
```

This is a mirror publish, not bidirectional sync. The target branch is force-updated from this repo's subtree history, so the standalone `.config` repo should be treated as an output, not the source of truth.
