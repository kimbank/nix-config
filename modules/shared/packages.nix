{ pkgs }:

with pkgs;
[
  android-tools
  bash-completion
  bat
  btop
  claude-code
  coreutils
  curl
  direnv
  docker
  fd
  fzf
  gh
  git
  jq
  (callPackage ./pkgs/im-select.nix { })
  nixd
  nixfmt
  # pnpm add -g opencode-ai@latest
  # pnpm up -g opencode-ai --latest
  # opencode
  pnpm
  ripgrep
  rustc
  cargo
  clippy
  rustfmt
  tmux
  tree
  unzip
  wget
  worktrunk
  ytsurf
  zip
]
