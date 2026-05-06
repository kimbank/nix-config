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
        if command -v openclaw >/dev/null 2>&1; then
          # Cache pnpm-managed completions outside the Nix store and refresh
          # them when the global CLI wrapper changes.
          openclaw_completion_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
          openclaw_completion_file="$openclaw_completion_dir/openclaw.zsh"
          openclaw_completion_tmp="$openclaw_completion_file.tmp"

          mkdir -p -- "$openclaw_completion_dir"
          if [[ ! -s "$openclaw_completion_file" || "$openclaw_completion_file" -ot "$(command -v openclaw)" ]]; then
            if openclaw completion --shell zsh >| "$openclaw_completion_tmp" 2>/dev/null; then
              mv -f -- "$openclaw_completion_tmp" "$openclaw_completion_file"
            else
              rm -f -- "$openclaw_completion_tmp"
            fi
          fi

          if [[ -r "$openclaw_completion_file" ]]; then
            source "$openclaw_completion_file"
          fi
          unset openclaw_completion_dir openclaw_completion_file openclaw_completion_tmp
        fi

        # Home Manager adds completion paths for each active profile even when a
        # profile doesn't ship every completion directory. Keep only the paths
        # that actually exist so oh-my-zsh doesn't keep rebuilding a bad dump.
        fpath=(''${^fpath}(N-/))

        expected_zcompdump_fpath="#omz fpath: $fpath"
        for dump in ''${ZDOTDIR:-$HOME}/.zcompdump(N) ''${ZDOTDIR:-$HOME}/.zcompdump-*(N); do
          [[ $dump == *.zwc ]] && continue
          if ! command grep -Fqx -- "$expected_zcompdump_fpath" "$dump" 2>/dev/null; then
            if [[ -d $dump ]]; then
              rm -rf -- "$dump"
            else
              rm -f -- "$dump"
            fi
            rm -f -- "$dump.zwc"
          fi
        done
        unset expected_zcompdump_fpath
      '')
    ];

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
  };

  zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  zellij = {
    enable = true;
  };
}
