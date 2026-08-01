# SSH public keys

This directory is exposed at `~/.config/secrets/ssh` through the repo-backed
Home Manager symlink. Store public SSH keys here when local tools need a stable
`IdentityFile` path. Never store private keys in this directory.

Payload files are ignored by default, so local public keys are not committed or
published to the standalone `.config` mirror. To intentionally track a specific
public key, add an explicit negation rule to the parent `.gitignore`, for example:

```gitignore
!/ssh/example.pub
```
