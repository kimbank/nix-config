#!/usr/bin/env bash
set -euo pipefail

script_name="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")" && pwd)"
begin_marker="# >>> github-local-auth (managed by ${script_name}) >>>"
end_marker="# <<< github-local-auth (managed by ${script_name}) <<<"

home_dir="${HOME}"
github_root="${home_dir}/Github"
env_file="${script_dir}/github-local-auth.env"
dry_run=0
verify=1
danger_plaintext_envrc=0

usage() {
  cat <<EOF
Usage: ${script_name} [--dry-run] [--no-verify] [--env-file PATH] [--home-dir PATH] [--github-root PATH]
       ${script_name} [-d|--danger] [--dry-run] [--no-verify] [--env-file PATH] [--home-dir PATH] [--github-root PATH]

Creates local-only GitHub auth setup from 1Password:
- bucket-level direnv .envrc files under \$HOME/Github/*
- public key files under \$HOME/.ssh/
- git includeIf config under ~/.gitconfig

Options:
  -d, --danger  resolve the GitHub token immediately and write plaintext GH_TOKEN
                into each bucket's .envrc instead of using an op:// reference

Configuration is loaded from an env file with entries like:
  GITHUB_1="bucket|vault|gh_item|ssh_item|git_name|git_email"
  GITHUB_1_TOKEN_FIELD=token
  GITHUB_1_PUBLIC_KEY_FIELD=public key

The script does not edit this Nix repo's tracked config.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=1
      shift
      ;;
    -d|--danger)
      danger_plaintext_envrc=1
      shift
      ;;
    --no-verify)
      verify=0
      shift
      ;;
    --env-file)
      env_file="$2"
      shift 2
      ;;
    --home-dir)
      home_dir="$2"
      shift 2
      ;;
    --github-root)
      github_root="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

optional_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run() {
  if [[ $dry_run -eq 1 ]]; then
    printf '+'
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
    return 0
  fi

  "$@"
}

write_file() {
  local path="$1"
  local content="$2"

  if [[ $dry_run -eq 1 ]]; then
    printf 'Would write %s\n' "$path"
    return 0
  fi

  mkdir -p "$(dirname "$path")"
  printf '%s' "$content" > "$path"
}

shell_escape() {
  local value="$1"
  local escaped

  printf -v escaped '%q' "$value"
  printf '%s\n' "$escaped"
}

update_managed_block() {
  local path="$1"
  local block="$2"
  local tmp

  tmp="$(mktemp)"

  if [[ -f "$path" ]]; then
    awk -v begin="$begin_marker" -v end="$end_marker" '
      $0 == begin { skip = 1; next }
      $0 == end { skip = 0; next }
      !skip { print }
    ' "$path" > "$tmp"
  fi

  if [[ $dry_run -eq 1 ]]; then
    printf 'Would update managed block in %s\n' "$path"
    rm -f "$tmp"
    return 0
  fi

  if [[ -s "$tmp" ]]; then
    printf '\n' >> "$tmp"
  fi

  printf '%s\n' "$begin_marker" >> "$tmp"
  printf '%s\n' "$block" >> "$tmp"
  printf '%s\n' "$end_marker" >> "$tmp"

  mkdir -p "$(dirname "$path")"
  mv "$tmp" "$path"
}

find_bucket_repo() {
  local bucket_dir="$1"
  local match

  match="$(find "$bucket_dir" -mindepth 1 -maxdepth 2 \( -type d -name .git -o -type f -name .git \) -print -quit 2>/dev/null || true)"
  if [[ -z "$match" ]]; then
    return 1
  fi

  printf '%s\n' "${match%/.git}"
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s\n' "$value"
}

load_env_file() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    echo "Config env file not found: $path" >&2
    echo "Copy ${script_dir}/github-local-auth.env.example to ${path} and edit it." >&2
    exit 1
  fi

  set -a
  # shellcheck source=/dev/null
  . "$path"
  set +a
}

load_specs() {
  local names
  local name

  mapfile -t names < <(compgen -A variable | grep -E '^GITHUB_[0-9]+$' | sort -t_ -k2,2n)

  if [[ ${#names[@]} -eq 0 ]]; then
    echo "No GITHUB_<n> entries found in ${env_file}" >&2
    exit 1
  fi

  bucket_specs=()
  bucket_var_names=()
  for name in "${names[@]}"; do
    bucket_var_names+=("$name")
    bucket_specs+=("${!name}")
  done
}

require_cmd op
require_cmd git
load_env_file "$env_file"
load_specs

bucket_specs=("${bucket_specs[@]}")

git_include_index_content=""

for i in "${!bucket_specs[@]}"; do
  spec="${bucket_specs[$i]}"
  IFS='|' read -r bucket vault gh_item ssh_item git_name git_email <<< "$spec"
  bucket="$(trim "$bucket")"
  vault="$(trim "$vault")"
  gh_item="$(trim "$gh_item")"
  ssh_item="$(trim "$ssh_item")"
  git_name="$(trim "$git_name")"
  git_email="$(trim "$git_email")"

  if [[ -z "$bucket" || -z "$vault" || -z "$gh_item" || -z "$ssh_item" ]]; then
    echo "Invalid bucket spec: ${spec}" >&2
    echo "Expected: bucket|vault|gh_item|ssh_item|git_name|git_email" >&2
    exit 1
  fi

  if [[ -n "$git_name" || -n "$git_email" ]]; then
    if [[ -z "$git_name" || -z "$git_email" ]]; then
      echo "Invalid Git identity in bucket spec: ${spec}" >&2
      echo "If you set git_name or git_email, you must set both." >&2
      echo "Expected identity order: ...|git_name|git_email" >&2
      if [[ -z "$git_email" && "$git_name" == *"@"* ]]; then
        echo "Hint: git_name looks like an email address. Did you swap the last two fields?" >&2
      fi
      exit 1
    fi
  fi

  prefix="${bucket_var_names[$i]}"
  token_field_var="${prefix}_TOKEN_FIELD"
  public_key_field_var="${prefix}_PUBLIC_KEY_FIELD"
  token_field="${!token_field_var:-token}"
  public_key_field="${!public_key_field_var:-public key}"

  bucket_dir="${github_root}/${bucket}"
  envrc_path="${bucket_dir}/.envrc"
  pubkey_path="${home_dir}/.ssh/${ssh_item}.pub"
  include_path="${home_dir}/.config/git/includes/${ssh_item}.inc"

  if [[ $dry_run -eq 0 ]]; then
    mkdir -p "$bucket_dir"
  else
    printf 'Would ensure directory %s\n' "$bucket_dir"
  fi

  if [[ $danger_plaintext_envrc -eq 1 ]]; then
    if [[ $dry_run -eq 1 ]]; then
      gh_token_value="<dry-run-danger-token>"
    else
      gh_token_value="$(op read --no-newline "op://${vault}/${gh_item}/${token_field}")"
    fi
    gh_token_escaped="$(shell_escape "$gh_token_value")"
    envrc_content=$(cat <<EOF
# WARNING: plaintext GH_TOKEN written by ${script_name} --danger
export GH_TOKEN=${gh_token_escaped}
EOF
)
  else
    envrc_content=$(cat <<EOF
export GH_TOKEN_REF="op://${vault}/${gh_item}/${token_field}"
export GH_TOKEN="\$(op read --no-newline "\$GH_TOKEN_REF")"
EOF
)
  fi
  write_file "$envrc_path" "$envrc_content"

  if [[ $dry_run -eq 1 ]]; then
    pubkey_value="ssh-ed25519 <dry-run> ${ssh_item}"
  else
    pubkey_value="$(op read --no-newline "op://${vault}/${ssh_item}/${public_key_field}")"
  fi
  write_file "$pubkey_path" "${pubkey_value}"$'\n'
  run chmod 600 "$pubkey_path"

  include_content=$(cat <<EOF
[core]
    sshCommand = ssh -o IdentitiesOnly=yes -o IdentityFile=${pubkey_path}
EOF
)
  if [[ -n "$git_name" && -n "$git_email" ]]; then
    include_content=$(cat <<EOF
[user]
    name = ${git_name}
    email = ${git_email}
${include_content}
EOF
)
  fi
  write_file "$include_path" "$include_content"

  git_include_index_content+="[includeIf \"gitdir:${github_root}/${bucket}/\"]
    path = ${include_path}
"

  if optional_cmd direnv; then
    run direnv allow "$bucket_dir"
  fi
done

write_file "${home_dir}/.config/git/includes/github-buckets.inc" "${git_include_index_content}"
update_managed_block "${home_dir}/.gitconfig" "$(cat <<EOF
[include]
    path = ${home_dir}/.config/git/includes/github-buckets.inc
EOF
)"

if [[ $verify -eq 1 ]]; then
  printf '\nVerification\n'

  if optional_cmd direnv && optional_cmd gh; then
    for spec in "${bucket_specs[@]}"; do
      IFS='|' read -r bucket vault gh_item ssh_item git_name git_email <<< "$spec"
      bucket="$(trim "$bucket")"
      bucket_dir="${github_root}/${bucket}"
      if [[ -d "$bucket_dir" ]]; then
        printf '[gh] %s -> ' "$bucket"
        if [[ $dry_run -eq 1 ]]; then
          printf 'skipped in dry-run\n'
        else
          direnv exec "$bucket_dir" gh api user -q .login
        fi
      fi
    done
  else
    printf 'Skipping gh verification because direnv or gh is not installed.\n'
  fi

  for spec in "${bucket_specs[@]}"; do
    IFS='|' read -r bucket vault gh_item ssh_item git_name git_email <<< "$spec"
    bucket="$(trim "$bucket")"
    bucket_dir="${github_root}/${bucket}"
    if repo_dir="$(find_bucket_repo "$bucket_dir")"; then
      printf '[git] %s repo: %s\n' "$bucket" "$repo_dir"
      if [[ $dry_run -eq 1 ]]; then
        printf '  skipped in dry-run\n'
      else
        git -C "$repo_dir" config --show-origin --get-regexp '^(user\.name|user\.email|core\.sshCommand)$' || true
      fi
    fi
  done
fi

printf '\nDone.\n'
