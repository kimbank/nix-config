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
      theme = "simple";
      plugins = [ "git" ];
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
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

        # Let worktrunk switch worktrees and change the current shell directory.
        if command -v wt >/dev/null 2>&1; then
          eval "$(wt config shell init zsh)"
        fi
      '')

      (lib.mkOrder 525 ''
        # Home Manager adds completion paths for each active profile even when a
        # profile doesn't ship every completion directory. Keep only the paths
        # that actually exist so oh-my-zsh doesn't keep rebuilding a bad dump.
        fpath=(''${^fpath}(N-/))

        expected_zcompdump_fpath="#omz fpath: $fpath"
        for dump in ''${ZDOTDIR:-$HOME}/.zcompdump(N) ''${ZDOTDIR:-$HOME}/.zcompdump-*(N); do
          [[ $dump == *.zwc ]] && continue
          if ! grep -Fqx -- "$expected_zcompdump_fpath" "$dump" 2>/dev/null; then
            rm -f -- "$dump" "$dump.zwc"
          fi
        done
        unset expected_zcompdump_fpath
      '')
    ];

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
      codexf = "codex --full-auto";
      codexd = "codex --dangerously-bypass-approvals-and-sandbox";
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

  mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      tools = {
        node = "24.14.0";
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

  neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  alacritty = {
    enable = true;
  };

  vscode = {
    enable = true;
    package = null;
    pname = "vscode";
    mutableExtensionsDir = true;
  };

  zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
