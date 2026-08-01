# Local secret material

Home Manager exposes this directory at `~/.config/secrets` as a writable,
repo-backed symlink. It provides stable local paths for public SSH keys and
`ssh-tresor` ciphertext without putting the payload files in Git.

## Layout

- [`ssh/`](ssh/README.md) stores local copies of public SSH keys used by tools
  that require an `IdentityFile` path.
- [`tresor/`](tresor/README.md) stores credentials encrypted with an SSH key
  provided by the configured SSH agent.

Never store plaintext credentials or private SSH keys anywhere under this
directory.

## Git and mirror policy

The directory-level [`.gitignore`](.gitignore) ignores every payload by default and
allowlists only documentation. This also keeps local payloads out of the
standalone `.config` mirror, which is published from Git-tracked content.

Public keys are not secret, but they stay local by default to avoid publishing
unnecessary account and key metadata. Encrypted `.tresor` files also stay local
by default. To intentionally track a specific file, add an explicit negation
rule to [`.gitignore`](.gitignore):

```gitignore
!/ssh/example.pub
!/tresor/example.tresor
```
