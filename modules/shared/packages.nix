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
  cliamp
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
  iperf3
  (callPackage ./pkgs/im-select.nix { })

  # J
  jdk17_headless
  jq

  # K
  k9s
  kubectl
  kubeseal
  kubernetes-helm

  # N
  nixd
  nixfmt

  # O
  oci-cli
  opentofu

  # P
  (callPackage ./pkgs/pnpm-for-host.nix { })
  poppler-utils

  # R
  rclone
  (callPackage ./pkgs/resume-texlive.nix { })
  ripgrep
  rustc
  rustfmt

  # S
  ssh-tresor

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
  (callPackage ./pkgs/ytsurf.nix { })

  # Z
  zip
]
