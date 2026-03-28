{ lib, pkgs, ... }:

let
  name = "kimbank";
  email = "kimeunhang@proton.me";
in
{
  zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" ];
    };

    initContent = lib.mkBefore ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      export PATH="$HOME/.local/bin:$PATH"
    '';

    # custom alias
    shellAliases = {
      ll = "ls -lah";
      cls = "clear";
      "친" = "clear";
      "ㅊㅣㄴ" = "clear";
      "히" = "gl";
      "ㅎㅣ" = "gl";
      wd = "while true; do tput cup 0 0; command duf; sleep 2; done";
      dp = "watch -n 1 \"docker ps -a --format \\\"table {{.ID}}\\t{{.Names}}\\t{{.Status}}\\\"\"";
      we = "webstorm .";
      clauded = "claude --dangerously-skip-permissions";
    };
  };

  git = {
    enable = true;
    lfs.enable = true;
    signing.format = null;

    settings = {
      user = {
        name = name;
        email = email;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
      core.editor = "nvim";
    };
  };

  bat.enable = true;

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      nui-nvim
      nvim-web-devicons
      telescope-nvim
      neo-tree-nvim
      nvim-treesitter
      lualine-nvim
      vim-tmux-navigator
    ];

    initLua = ''
      dofile(vim.fn.stdpath("config") .. "/local-init.lua")
    '';
  };

  vscode = {
    enable = true;
    package = null;
    pname = "vscode";
    mutableExtensionsDir = true;

    profiles.default.extensions = with pkgs.vscode-extensions; [ ];
  };

  zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
