# Local 1Password configuration

Home Manager links this directory to `~/.config/1Password` as a writable,
repo-backed symlink. This is the official location used by the 1Password SSH
Agent's optional configuration file:

```text
~/.config/1Password/ssh/agent.toml
```

The file controls which SSH keys the Agent makes available and the order in
which it offers them. It does not contain private keys. This repository tracks
an account-wide selector for `my.1password.com`, which makes eligible
SSH keys from every vault in that account available to the Agent.

## Tracking policy

The directory-level `.gitignore` tracks `ssh/agent.toml`, this documentation,
and the ignore policy itself while ignoring any other local state. The tracked
file intentionally publishes the account sign-in address but no vault names,
item names, public keys, private keys, or credentials.

Expected local layout:

```text
~/.config/1Password/
└── ssh/
    └── agent.toml
```

Keep the directory accessible only to the user. After changing the file,
inspect the Agent's effective key order:

```sh
SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" \
  ssh-add -l
```

The private keys remain inside 1Password. This TOML file only selects the
eligible keys exposed through the SSH Agent. Since the account-wide selector
may expose more than six keys, use `IdentityFile` with `IdentitiesOnly yes` for
hosts that require deterministic key selection.
