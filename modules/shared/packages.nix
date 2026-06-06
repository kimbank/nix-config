{ pkgs }:

let
  resumeTexLive = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-small
      latexmk
      collection-langkorean
      fontspec
      luatexko
      polyglossia
      titlesec
      marvosym
      enumitem
      pgf
      preprint
      ;
  };
in
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

  # L
  resumeTexLive

  # N
  nixd
  nixfmt

  # O
  oci-cli
  opentofu

  # P
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
