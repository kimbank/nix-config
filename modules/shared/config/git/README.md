# Local Git configuration

Home Manager exposes this directory at `~/.config/git` as a writable,
repo-backed symlink. Git and Git LFS are installed from
`modules/shared/packages.nix`; Home Manager's `programs.git` module stays
disabled so it does not generate a competing global identity or config file.

## Tracking policy

The directory-level `.gitignore` tracks the shared `config`, this documentation,
and the ignore policy itself. Account include files may contain account names,
email addresses, checkout paths, and SSH public-key paths, so `github/` stays
local and must not enter this repository or the standalone `.config` mirror.

Expected local layout:

```text
~/.config/git/
├── config
└── github/
    ├── index.inc
    ├── github-kimbank.inc
    └── ...
```

The live files are stored in the matching ignored paths under
`modules/shared/config/git/`. Because the whole directory is linked, editing
either path edits the same files.

## Multiple GitHub accounts

The tracked `config` keeps shared, non-identity defaults and refers to a local
directory router:

```gitconfig
[include]
    path = github/index.inc
```

The router can select an account by checkout directory:

```gitconfig
[includeIf "gitdir:~/Github/example/"]
    path = github-example.inc
```

Each account file should provide both its commit identity and deterministic SSH
key selection:

```gitconfig
[user]
    name = example
    email = example@example.com
[core]
    sshCommand = ssh -o IdentitiesOnly=yes -o IdentityFile=$HOME/.config/secrets/ssh/github-example.pub
```

Git silently ignores the include when the local router does not exist. The
tracked config sets `user.useConfigOnly = true`, so a missing account identity
causes commits to fail clearly instead of letting Git guess one from the host.

The `IdentityFile` is a public key. OpenSSH uses it to select the matching key
from the configured 1Password SSH Agent, which performs the private-key signing.

Do not define a fallback `user.name`, `user.email`, or GitHub `sshCommand` in the
top-level config. A repository outside the account buckets should fail clearly
instead of silently committing or authenticating as the wrong account.

## Verification

From a repository inside a configured bucket, inspect every contributing file:

```sh
git config --show-origin --show-scope --list
git config --get user.name
git config --get user.email
git config --get core.sshCommand
```

If an old `~/.gitconfig` still exists, remove its active settings after this
directory has been switched successfully. Git reads it after
`~/.config/git/config`, so active legacy values can override this config.
