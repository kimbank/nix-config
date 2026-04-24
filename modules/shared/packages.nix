{ pkgs }:

with pkgs;
[
  android-tools
  bash-completion
  ast-grep
  awscli2
  bat
  btop
  coreutils
  curl
  direnv
  docker
  kubectl
  kubeseal
  fd
  fzf
  gh
  git
  jq
  jdk17_headless
  (callPackage ./pkgs/im-select.nix { })
  nixd
  nixfmt
  opentofu
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
  witr
  worktrunk
  ytsurf
  zip
]
