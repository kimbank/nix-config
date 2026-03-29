{ pkgs }:

with pkgs; [
  bash-completion
  bat
  btop
  claude-code
  coreutils
  curl
  direnv
  fd
  fzf
  gh
  git
  jq
  (callPackage ./pkgs/im-select.nix { })
  nixd
  nixfmt
  nodejs_24
  pnpm
  ripgrep
  tmux
  tree
  unzip
  wget
  ytsurf
  zip
]
