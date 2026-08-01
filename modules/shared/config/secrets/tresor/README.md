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

## Add a secret from 1Password

When working from the full `nix-config` checkout, prefer the maintained helper:

```sh
./scripts/ssh-tresor-from-1password/main.sh
```

It performs the same interactive flow shown below while protecting an existing
destination from a partially failed encryption. The inline version remains here
so the standalone `.config` mirror is self-contained.

Sign in to the 1Password CLI first. The following paste-ready zsh function asks
for the 1Password secret reference, shows the SSH keys available from the agent,
asks which fingerprint should decrypt the payload, and accepts either a local
file name or an absolute output path:

```zsh
encrypt_op_tresor() {
  setopt localoptions pipefail

  local op_ref fingerprint output_name output

  printf '1Password reference (op://...): '
  IFS= read -r op_ref

  if (( ${#op_ref} >= 2 )); then
    local first="${op_ref[1]}"
    local last="${op_ref[-1]}"
    if [[ ( "$first" == '"' && "$last" == '"' ) || \
          ( "$first" == "'" && "$last" == "'" ) ]]; then
      op_ref="${op_ref[2,-2]}"
    fi
  fi

  ssh-tresor list-keys || return 1
  printf 'SSH key fingerprint (SHA256:...): '
  IFS= read -r fingerprint

  local output_dir="$HOME/.config/secrets/tresor"
  printf 'Output filename under %s (Enter for absolute path): ' "$output_dir"
  IFS= read -r output_name

  if [[ -n "$output_name" ]]; then
    if [[ "$output_name" == */* || "$output_name" == "." || \
          "$output_name" == ".." ]]; then
      print -u2 -- 'Error: output filename must not contain a slash.'
      return 1
    fi
    [[ "$output_name" == *.tresor ]] || output_name+='.tresor'
    output="$output_dir/$output_name"
  else
    printf 'Output path (absolute): '
    IFS= read -r output
  fi

  if [[ "$output" != /* ]]; then
    print -u2 -- 'Error: output path must be absolute.'
    return 1
  fi

  (
    umask 077
    op read --no-newline "$op_ref" |
      ssh-tresor encrypt \
        --armor \
        --key "$fingerprint" \
        --output "$output"
  ) || return 1

  ssh-tresor list-slots "$output"
}

encrypt_op_tresor
unset -f encrypt_op_tresor
```

Entering `github-token` at the file-name prompt writes
`~/.config/secrets/tresor/github-token.tresor`. Press Enter there to enter a
different absolute path. Text entered at the absolute-path prompt does not
expand `~` or `$HOME`.

An `op://` reference pasted as `"op://..."` or `'op://...'` is accepted; only
one matching pair of surrounding quotes is removed.

The token passes directly from `op read` to `ssh-tresor` without appearing in
shell history or a shell variable. `--no-newline` avoids encrypting a trailing
line break, while `--armor` stores text-safe base64 with headers and footers for
easier copying and transfer between systems. Armor changes the representation,
not the encryption strength. The local `umask` creates a new output file without
group or other-user permissions.

Omitting `--key` selects the first available key, so an explicit fingerprint is
preferable when the 1Password agent exposes multiple keys. After encryption,
`list-slots` confirms which fingerprints can decrypt the file without revealing
the plaintext.

## Decrypt from direnv

A bucket-level `.envrc` can decrypt the token only while the matching SSH key is
available through 1Password:

```sh
export GH_TOKEN="$(
  ssh-tresor decrypt \
    "$HOME/.config/secrets/tresor/github-token.tresor"
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
tresor="$HOME/.config/secrets/tresor/github-token.tresor"

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
