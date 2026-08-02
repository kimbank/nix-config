{ lib, pkgs, ... }:

{
  zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Keep separate dumps for Apple's zsh and the Nix-provided zsh while
    # storing both alongside oh-my-zsh's other cache files.
    localVariables.ZSH_COMPDUMP = "$ZSH_CACHE_DIR/zcompdump-$ZSH_VERSION";

    oh-my-zsh = {
      enable = true;
      theme = "simple";
      plugins = [ "git" ];
    };

    # Worktrunk defines a shell function so worktree switches can change the
    # current shell directory. Load it after oh-my-zsh has initialized compdef.
    initContent = lib.mkOrder 850 ''
      eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
    '';

    # custom alias
    shellAliases = {
      ll = "ls -lah";
      cls = "clear";
      grep = "rg";
      sg = "ast-grep";
      glf = "gl && gf";
      "친" = "clear";
      "ㅊㅣㄴ" = "clear";
      "히" = "gl";
      "ㅎㅣ" = "gl";
      "힐" = "glf";
      "ㅎㅣㄹ" = "glf";
      "ㅣㅣ" = "ll";
      "ㄷ턋" = "exit";
      "nvim." = "nvim .";
      "nvim~" = "nvim ~";
      "code." = "code .";
      exot = "exit";
      pug = "pnpm_config_minimum_release_age=0 pnpm up -g";
      wd = "while true; do tput cup 0 0; command duf; sleep 2; done";
      dp = "watch -n 1 \"docker ps -a --format \\\"table {{.ID}}\\t{{.Names}}\\t{{.Status}}\\\"\"";
      we = "webstorm .";
      clauded = "claude --dangerously-skip-permissions";
      codexf = "codex --full-auto";
      codexd = "codex --dangerously-bypass-approvals-and-sandbox";
      ck = "colima kubernetes";
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      pwdc = "printf %s \"$PWD\" | pbcopy";
    };
  };

  gh = {
    enable = true;
    settings.git_protocol = "ssh";

    # GitHub authentication comes from GH_TOKEN and Git remotes use SSH.
    gitCredentialHelper.enable = false;
  };

  bat.enable = true;

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      # Home Manager writes this to ~/.config/mise/config.toml for user-wide defaults.
      # Keep global fallbacks on moving channels; repo-local mise files should pin specifics.
      tools = {
        bun = "latest";
        deno = "latest";
        node = "lts";
      };

      settings = {
        idiomatic_version_file_enable_tools = [ "node" ];
      };
    };
  };

  fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  mpv = {
    enable = true;

    config = {
      hwdec = "auto";
      osd-fractions = true;
      osd-font-size = 48;
      osd-level = 1;
      osd-msg2 = "Timestamp: \${playback-time/full}";
    };

    bindings.t = "cycle-values osd-level 1 2";

    # Keep URL playback on the pinned nixpkgs yt-dlp regardless of shell/app PATH.
    scriptOpts.ytdl_hook.ytdl_path = lib.getExe pkgs.yt-dlp;
  };

  neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    # The repo owns ~/.config/nvim/init.lua through an out-of-store symlink.
    # Load Home Manager's generated provider setup through the wrapper instead.
    sideloadInitLua = true;
    # Preserve the pre-26.05 Home Manager defaults explicitly.
    withPython3 = true;
    withRuby = true;
  };

  vscode = {
    enable = true;
    package = null;
    mutableExtensionsDir = true;
  };

  zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  zellij = {
    enable = true;
  };
}
