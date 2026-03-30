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

The actual `scripts/github-local-auth.env` file is ignored by git. Use `--env-file /path/to/file` if you want to keep the config elsewhere.
