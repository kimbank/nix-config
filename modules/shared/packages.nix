{ pkgs }:

let
  pnpmForHost =
    if pkgs.stdenv.isDarwin && pkgs.stdenv.hostPlatform.isAarch64 then
      # TODO: Remove this override once the pinned nixpkgs includes the Node 24
      # Darwin fd-tracking fix. The affected Node build can make pnpm 11 emit
      # unmanaged-fd warnings and abort in libuv after a successful install.
      # https://github.com/NixOS/nixpkgs/issues/536039
      # https://github.com/NixOS/nixpkgs/issues/525627
      pkgs.pnpm.override { nodejs-slim = pkgs.nodejs-slim_22; }
    else
      pkgs.pnpm;
  resumeTexLive = pkgs.texliveSmall.withPackages (
    ps: with ps; [
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
    ]
  );
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
  pnpmForHost
  poppler-utils

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
