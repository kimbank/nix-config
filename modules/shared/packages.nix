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
  cmake
  coreutils
  curl

  # D
  direnv
  docker

  # F
  fd
  fzf

  # G
  git
  git-lfs
  glab

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
  opus

  # P
  (callPackage ./pkgs/pnpm-for-host.nix { })
  poppler-utils
  pkg-config

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
