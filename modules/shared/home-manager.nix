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
      telescope-nvim
      nvim-treesitter
      lualine-nvim
      vim-tmux-navigator
    ];

    initLua = ''
      dofile(vim.fn.stdpath("config") .. "/local-init.lua")
    '';
  };

  zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
