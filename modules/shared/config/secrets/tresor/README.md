# ssh-tresor payloads

This directory is exposed at `~/.config/secrets/tresor` through the repo-backed
Home Manager symlink. Store only files encrypted by
[`ssh-tresor`](https://github.com/haraldh/ssh-tresor); never store a plaintext
token or credential here.

`ssh-tresor` asks an SSH agent to sign a challenge, derives encryption material
from the signature, and encrypts the payload with AES-256-GCM. The private SSH
key never leaves the agent. A tresor may contain multiple key slots so that more
than one SSH key can decrypt the same payload.

## Prerequisites

This configuration exports the 1Password SSH agent socket as `SSH_AUTH_SOCK`.
Keep 1Password running and unlocked, enable its SSH agent, and start a fresh
login shell after applying the Home Manager configuration:

```sh
exec zsh -l
ssh-tresor list-keys
```

`list-keys` prints a fingerprint such as `SHA256:...` for every key currently
offered by the agent. A fingerprint identifies the public key, not the device:
the same 1Password SSH key has the same fingerprint on another device, although
the set of keys exposed by each device or agent may differ.

## Encrypt a GitHub token

Read the token without echoing it or placing it in shell history, then explicitly
select the intended SSH key by fingerprint:

```zsh
read -rs 'github_token?GitHub token: '
printf '\n'
printf '%s' "$github_token" | ssh-tresor encrypt \
  --armor \
  --key 'SHA256:REPLACE_WITH_THE_KEY_FINGERPRINT' \
  --output "$HOME/.config/secrets/tresor/kimbank-gh-token.tresor"
unset github_token
```

`--armor` produces a text-safe representation. Omitting `--key` selects the
first available key, so an explicit fingerprint is preferable when the
1Password agent exposes multiple keys.

Confirm which key slots were written without revealing the plaintext:

```sh
ssh-tresor list-slots \
  "$HOME/.config/secrets/tresor/kimbank-gh-token.tresor"
```

## Decrypt from direnv

A bucket-level `.envrc` can decrypt the token only while the matching SSH key is
available through 1Password:

```sh
export GH_TOKEN="$(
  ssh-tresor decrypt \
    "$HOME/.config/secrets/tresor/kimbank-gh-token.tresor"
)"
```

Run `direnv allow` after creating or changing the `.envrc`. Child directories
inherit the exported value unless another `.envrc` replaces or unloads it.
1Password may request approval when direnv evaluates the command. After
decryption, `GH_TOKEN` is ordinary plaintext process environment data until
direnv unloads the environment; `ssh-tresor` protects the token at rest, not
after export.

## Manage key slots

Add a replacement or recovery key before removing an old key:

```sh
tresor="$HOME/.config/secrets/tresor/kimbank-gh-token.tresor"

ssh-tresor add-key --in-place \
  --key 'SHA256:NEW_KEY_FINGERPRINT' "$tresor"
ssh-tresor list-slots "$tresor"
ssh-tresor remove-key --in-place \
  --key 'SHA256:OLD_KEY_FINGERPRINT' "$tresor"
```

Both an existing decrypting key and the new key must be available when adding a
slot. Do not remove the final usable slot; there is no recovery without a
matching SSH key.

## Troubleshooting

If `ssh-tresor list-keys` reports `No keys found in SSH agent`:

1. Check that `SSH_AUTH_SOCK` points to the 1Password agent socket with
   `printf '%s\n' "$SSH_AUTH_SOCK"`.
2. Confirm that 1Password is running, unlocked, and has its SSH agent enabled.
3. Run `ssh-add -L` to see whether the current agent exposes public keys.
4. After a Home Manager switch, run `exec zsh -l` and retry
   `ssh-tresor list-keys`.

If the file has slots but decryption fails, compare `ssh-tresor list-slots` with
`ssh-tresor list-keys`; at least one fingerprint must match and be available.

Payload files are ignored by default, so they are not committed or published to
the standalone `.config` mirror. See the parent [secrets policy](../README.md)
before intentionally allowlisting an encrypted file.
