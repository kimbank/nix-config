{ pkgs }:

with pkgs;
[
  # A
  android-tools
  ast-grep
  awscli2

  # B
  bash-completion
  bat
  btop

  # C
  cargo
  clippy
  coreutils
  curl

  # D
  direnv
  docker

  # F
  fd
  fzf

  # G
  gh
  git

  # I
  (callPackage ./pkgs/im-select.nix { })

  # J
  jdk17_headless
  jq

  # K
  kubectl
  kubeseal

  # N
  nixd
  nixfmt

  # O
  opentofu

  # P
  # pnpm add -g opencode-ai@latest
  # pnpm up -g opencode-ai --latest
  # opencode
  pnpm

  # R
  ripgrep
  rustc
  rustfmt

  # T
  tmux
  tree

  # U
  unzip

  # W
  wget
  witr
  worktrunk

  # Y
  ytsurf

  # Z
  zip
]
