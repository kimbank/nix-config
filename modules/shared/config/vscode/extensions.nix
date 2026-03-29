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
    name = "vscode-dbml";
    publisher = "matt-meyers";
    version = "0.4.1";
    sha256 = "1nr8cpqff7g7q6iv4zi7xjs3mif3bc04nqr9chc1yx02r3hpx0jl";
  }
  {
    name = "vscode-mermaid-chart";
    publisher = "MermaidChart";
    version = "2.6.2";
    sha256 = "0w9hdpl8arni7javbb90jszwwp996a75yjz0hgw4mz164b0zpz5w";
  }
  {
    name = "vscode-python-envs";
    publisher = "ms-python";
    version = "1.24.0";
    sha256 = "0yd4s0ri6vjh385z87g311v806r4jnl2ay612c7z7js1yjvl1h2s";
  }
  {
    name = "tensorboard";
    publisher = "ms-toolsai";
    version = "2023.10.1002992421";
    sha256 = "1fpxrxpmchbnhzn62jn2akcig76ghnkv5l3fiziiax58z6xr1ncq";
  }
  {
    name = "cpp-devtools";
    publisher = "ms-vscode";
    version = "0.4.6";
    sha256 = "0vk8pxnckyrk13y3rfl35bwqfxgsmha3k4c75l4kgpnqir804r9b";
  }
  {
    name = "leaper";
    publisher = "OnlyLys";
    version = "0.10.5";
    sha256 = "00lr2811zckfgmqbff51r67wps03izasz6qmcmgmvx2vb2047my4";
  }
  {
    name = "excalidraw-editor";
    publisher = "pomdtr";
    version = "3.9.1";
    sha256 = "0ghjmqh2dmjzi29khk90dacl7p2225zj20k6r0z3n401cpq85fpw";
  }
  {
    name = "sqlite-viewer";
    publisher = "qwtel";
    version = "25.12.2";
    sha256 = "0vvvbqfz37bcp1hjl3zja1bws4dx648nc70z7pdfavb85li4f59b";
  }
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
  {
    name = "luahelper";
    publisher = "yinfei";
    version = "0.2.29";
    sha256 = "1sk6335z509bqnr6bd73y6ypy8k30d68jp1ls0dy9gnsbli56r7z";
  }
]
