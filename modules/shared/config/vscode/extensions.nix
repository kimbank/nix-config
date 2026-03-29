{ pkgs }:

with pkgs.vscode-extensions;
[
  alefragnani.bookmarks
  anthropic.claude-code
  bbenoist.nix
  bradlc.vscode-tailwindcss
  dart-code.dart-code
  dart-code.flutter
  dbaeumer.vscode-eslint
  docker.docker
  eamodio.gitlens
  esbenp.prettier-vscode
  Google.gemini-cli-vscode-ide-companion
  graphql.vscode-graphql
  graphql.vscode-graphql-syntax
  jnoortheen.nix-ide
  james-yu.latex-workshop
  jock.svg
  mechatroner.rainbow-csv
  ms-ceintl.vscode-language-pack-ko
  ms-python.debugpy
  ms-python.python
  ms-python.vscode-pylance
  ms-toolsai.jupyter
  ms-toolsai.jupyter-keymap
  ms-toolsai.jupyter-renderers
  ms-toolsai.vscode-jupyter-cell-tags
  ms-toolsai.vscode-jupyter-slideshow
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-ssh-edit
  ms-vscode.cmake-tools
  ms-vscode.cpptools
  ms-vscode.makefile-tools
  ms-vscode.remote-explorer
  oderwat.indent-rainbow
  pkief.material-icon-theme
  prisma.prisma
  redhat.java
  ritwickdey.liveserver
  streetsidesoftware.code-spell-checker
  styled-components.vscode-styled-components
  tomoki1207.pdf
  vscjava.vscode-gradle
  vscjava.vscode-java-debug
  vscjava.vscode-java-dependency
  vscjava.vscode-java-test
  vscjava.vscode-maven
  wakatime.vscode-wakatime
]
++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
  {
    name = "vscode-todo-highlight";
    publisher = "wayou";
    version = "1.0.5";
    sha256 = "1sg4zbr1jgj9adsj3rik5flcn6cbr4k2pzxi446rfzbzvcqns189";
  }
  {
    name = "tab-out-or-reindent";
    publisher = "yeannylam";
    version = "0.3.1";
    sha256 = "1bh9v0sjmb7bqg88ayblcdzpzvpip56nds12xnv4864ycm5nz50w";
  }
]
