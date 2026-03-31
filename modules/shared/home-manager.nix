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

      # Keep newly spawned shells on ABC so terminal editing starts in English.
      # if command -v im-select >/dev/null 2>&1; then
      #   im-select com.apple.keylayout.ABC >/dev/null 2>&1 || true
      # fi

      # Keep Toolbox-generated IDE launchers available from new shells.
      export PATH="$HOME/.local/bin:$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"
    '';

    # custom alias
    shellAliases = {
      ll = "ls -lah";
      cls = "clear";
      "친" = "clear";
      "ㅊㅣㄴ" = "clear";
      "히" = "gl";
      "ㅎㅣ" = "gl";
      "ㅣㅣ" = "ll";
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
  };

  vscode = {
    enable = true;
    package = null;
    pname = "vscode";
    mutableExtensionsDir = true;

    profiles.default = {
      extensions = import ./config/vscode/extensions.nix { inherit pkgs; };
    };
  };

  zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
