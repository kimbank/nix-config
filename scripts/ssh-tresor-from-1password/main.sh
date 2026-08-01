#!/usr/bin/env bash
set -euo pipefail

script_name="$(basename "$0")"
op_reference=""
fingerprint=""
output_name=""
output_path=""
force=0
tmp_output=""

usage() {
  cat <<EOF
Usage: ${script_name} [OPTIONS]

Read a secret from 1Password and encrypt it with an SSH-agent key.
Interactive prompts are used for values not supplied as options.

Options:
  --op-reference REF      1Password reference beginning with op://
  --fingerprint SHA256:ID SSH key fingerprint shown by ssh-tresor list-keys
  --name NAME             Write NAME.tresor under ~/.config/secrets/tresor
  --output ABSOLUTE_PATH  Destination for the armored .tresor file
  -f, --force             Replace an existing destination without prompting
  -h, --help              Show this help
EOF
}

require_value() {
  local option="$1"
  local value="${2:-}"

  if [[ -z "$value" ]]; then
    printf 'Missing value for %s\n' "$option" >&2
    usage >&2
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --op-reference)
      require_value "$1" "${2:-}"
      op_reference="$2"
      shift 2
      ;;
    --fingerprint)
      require_value "$1" "${2:-}"
      fingerprint="$2"
      shift 2
      ;;
    --output)
      require_value "$1" "${2:-}"
      output_path="$2"
      shift 2
      ;;
    --name)
      require_value "$1" "${2:-}"
      output_name="$2"
      shift 2
      ;;
    -f|--force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

strip_matching_outer_quotes() {
  local value="$1"
  local first
  local last

  if [[ ${#value} -ge 2 ]]; then
    first="${value:0:1}"
    last="${value: -1}"
    if [[ ( "$first" == '"' && "$last" == '"' ) || \
          ( "$first" == "'" && "$last" == "'" ) ]]; then
      value="${value:1:${#value}-2}"
    fi
  fi

  printf '%s' "$value"
}

cleanup() {
  if [[ -n "$tmp_output" && -e "$tmp_output" ]]; then
    rm -f "$tmp_output"
  fi
}

trap cleanup EXIT
umask 077

require_cmd op
require_cmd ssh-tresor

if [[ -z "$op_reference" ]]; then
  printf '1Password reference (op://...): '
  IFS= read -r op_reference
fi

op_reference="$(strip_matching_outer_quotes "$op_reference")"

if [[ "$op_reference" != op://* ]]; then
  printf '1Password reference must begin with op://\n' >&2
  exit 1
fi

printf 'SSH keys available from the current agent:\n'
ssh-tresor list-keys

if [[ -z "$fingerprint" ]]; then
  printf 'SSH key fingerprint (SHA256:...): '
  IFS= read -r fingerprint
fi

if [[ "$fingerprint" != SHA256:* ]]; then
  printf 'SSH key fingerprint must begin with SHA256:\n' >&2
  exit 1
fi

if [[ -n "$output_name" && -n "$output_path" ]]; then
  printf 'Use either --name or --output, not both.\n' >&2
  exit 1
fi

default_output_dir="${HOME}/.config/secrets/tresor"

if [[ -z "$output_name" && -z "$output_path" ]]; then
  printf 'Output filename under %s (Enter for absolute path): ' \
    "$default_output_dir"
  IFS= read -r output_name
fi

if [[ -n "$output_name" ]]; then
  if [[ "$output_name" == */* || "$output_name" == "." || \
        "$output_name" == ".." ]]; then
    printf 'Output filename must be a single file name without slashes.\n' >&2
    exit 1
  fi

  if [[ "$output_name" != *.tresor ]]; then
    output_name="${output_name}.tresor"
  fi
  output_path="${default_output_dir}/${output_name}"
elif [[ -z "$output_path" ]]; then
  printf 'Output path (absolute): '
  IFS= read -r output_path
fi

if [[ "$output_path" != /* || "$output_path" == "/" ]]; then
  printf 'Output path must be an absolute file path.\n' >&2
  exit 1
fi

output_dir="$(dirname "$output_path")"
mkdir -p "$output_dir"

if [[ -e "$output_path" && $force -eq 0 ]]; then
  if [[ ! -t 0 ]]; then
    printf 'Output already exists; use --force to replace it: %s\n' \
      "$output_path" >&2
    exit 1
  fi

  printf 'Output already exists. Replace it? [y/N]: '
  IFS= read -r confirmation
  case "$confirmation" in
    y|Y|yes|YES|Yes) ;;
    *)
      printf 'Cancelled.\n'
      exit 0
      ;;
  esac
fi

tmp_output="$(mktemp "${output_dir}/.ssh-tresor.XXXXXX")"

op read --no-newline "$op_reference" |
  ssh-tresor encrypt \
    --armor \
    --key "$fingerprint" \
    --output "$tmp_output"

chmod 600 "$tmp_output"
mv -f "$tmp_output" "$output_path"
tmp_output=""

printf 'Encrypted secret written to %s\n' "$output_path"
ssh-tresor list-slots "$output_path"
