# OpenSSH client configuration

Home Manager links this directory to `~/.config/ssh`. OpenSSH does not discover
that XDG-style path automatically. To opt in, add this entry point manually to
`~/.ssh/config`:

```sshconfig
Include ~/.config/ssh/index.conf
```

Home Manager deliberately does not own `~/.ssh/config`. This keeps the shared
configuration opt-in and leaves all of `~/.ssh`, including `known_hosts`,
private keys, and runtime sockets, outside the repo-backed directory.

## Tracking policy

The directory-level `.gitignore` tracks the shared `index.conf`, this
documentation, and the ignore policy itself. Files under `local/` may contain
private host names, addresses, users, and checkout paths, so they stay local and
must not enter this repository or the standalone `.config` mirror.

Expected layout:

```text
~/.config/ssh -> modules/shared/config/ssh
├── index.conf
└── local/
    └── index.conf
```

The separate unmanaged entry point remains at `~/.ssh/config`. Put the `Include`
near the top when this shared configuration should take precedence over later
defaults. Put an intentional host-specific override before it when that local
value must win, because OpenSSH normally keeps the first value it obtains.

## Evaluation order

For ordinary single-value directives, OpenSSH keeps the first value it obtains:

1. command-line options such as `-o` and `-i`
2. `~/.ssh/config` and files included from it
3. `/etc/ssh/ssh_config` and its includes
4. built-in defaults

`Include` is evaluated at its location. Put specific host configuration before
the final `Host *` defaults. Unlike Git includes, a relative user `Include` path
is resolved from `~/.ssh`, not from the directory of the file containing the
directive. Use explicit `~/` paths as in these files.

Some directives are multi-value exceptions. In particular, multiple
`IdentityFile` entries accumulate and are tried in sequence.

## Local hosts

The tracked `index.conf` loads every ignored local fragment in lexical order:

```sshconfig
Include ~/.config/ssh/local/*.conf
```

Keep host-specific declarations in those fragments. For example:

```sshconfig
Host example
    HostName 192.0.2.10
    User ubuntu
    IdentityFile ~/.config/secrets/ssh/example.pub
    IdentitiesOnly yes
```

The `IdentityFile` may be a public key whose matching private key is held by the
1Password SSH Agent. The tracked fallback `IdentityAgent` selects that agent for
OpenSSH clients, including GUI applications that do not inherit a shell's
`SSH_AUTH_SOCK`.

## Verification

Inspect the fully evaluated configuration without connecting:

```sh
ssh -G example
ssh -G git@github.com | rg '^(user|hostname|identityagent|identityfile|identitiesonly) '
```

Use `ssh -vv example` only when connection and authentication tracing is needed.
If these commands do not show values from `index.conf`, confirm that
`~/.ssh/config` contains `Include ~/.config/ssh/index.conf`.
