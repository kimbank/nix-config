{
  config,
  pkgs,
  lib,
  repoRoot ? null,
  ...
}:

let
  loginUser = "kimbank";
  additionalFiles = import ./files.nix {
    user = loginUser;
    inherit config pkgs;
  };
in
{
  imports = [ ./dock ];

  users.users.${loginUser} = {
    name = loginUser;
    home = "/Users/${loginUser}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    brews = [ ];
    casks = pkgs.callPackage ./casks.nix { };
    masApps = { };
  };

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "hm-backup";

    users.${loginUser} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      let
        sharedFiles = import ../shared/files.nix {
          inherit config repoRoot;
        };
        colimaConfigTarget = ".colima/default/colima.yaml";
        colimaDefaultSettings = {
          cpu = 4;
          memory = 8;
          disk = 150;
          # Some Colima versions do not reliably infer the runtime from an
          # otherwise minimal config on restart, so keep Docker explicit.
          runtime = "docker";
          kubernetes = {
            enabled = false; # `ck start` to enable when needed
            k3sArgs = [ "--disable=traefik" ];
          };
        };
        colimaDefaultConfig = (pkgs.formats.yaml { }).generate "colima.yaml" colimaDefaultSettings;
      in
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
            {
              # Home Manager's Colima module otherwise links this file from the
              # Nix store when profile settings are set, which makes a direct
              # `colima start` fail when the CLI tries to rewrite the profile.
              "${colimaConfigTarget}".enable = lib.mkForce false;
            }
          ];
          sessionVariables = {
            # Keep pnpm global binaries outside mise-managed Node installs.
            PNPM_HOME = "$HOME/Library/pnpm";
            JAVA_HOME = pkgs.jdk17_headless.home;
            # Android Studio installs the SDK here on macOS; keep the CLI env
            # declarative so local Android/EAS tooling sees a stable path.
            ANDROID_HOME = "$HOME/Library/Android/sdk";
            ANDROID_SDK_ROOT = "$HOME/Library/Android/sdk";
          };
          sessionPath = [
            "$HOME/Library/pnpm"
            "$HOME/Library/Android/sdk/platform-tools"
            "$HOME/Library/Android/sdk/emulator"
            "$HOME/Library/Android/sdk/cmdline-tools/latest/bin"
          ];
          stateVersion = "24.11";
        };

        home.activation.installWritableColimaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          target="$HOME/${colimaConfigTarget}"

          run ${pkgs.coreutils}/bin/mkdir -p "''${target%/*}"
          run ${pkgs.coreutils}/bin/rm -f "$target"
          run ${pkgs.coreutils}/bin/cp "${colimaDefaultConfig}" "$target"
          run ${pkgs.coreutils}/bin/chmod 0644 "$target"
        '';

        targets.darwin = {
          copyApps.enable = true;
          linkApps.enable = false;
          defaults = {
            NSGlobalDomain."com.apple.mouse.tapBehavior" = 0;
            "com.steipete.codexbar" = {
              SUAutomaticallyUpdate = false;
              SUEnableAutomaticChecks = false;
            };
          };
          currentHostDefaults = {
            NSGlobalDomain."com.apple.mouse.tapBehavior" = 0;
            # Hidden menu bar spacing prefs. Use currentHost because macOS reads
            # these from `defaults -currentHost read -globalDomain ...`.
            NSGlobalDomain.NSStatusItemSpacing = 6;
            NSGlobalDomain.NSStatusItemSelectionPadding = 3;
            "com.apple.screensaver".idleTime = 0;
            # Accessibility prefs under com.apple.universalaccess are host-scoped
            # on fresh macOS installs and can fail during nix-darwin's
            # system.defaults activation step.
            "com.apple.universalaccess".closeViewScrollWheelToggle = true;
            "com.apple.universalaccess".reduceMotion = true;
          };
        };

        services.colima = {
          enable = true;
          profiles.default = {
            isActive = true;
            isService = true;
            setDockerHost = true;
            # Keep the Colima profile declarative in Nix, but install a normal
            # file into ~/.colima/default/colima.yaml during activation so a
            # direct `colima start` can persist runtime flags.
            settings = colimaDefaultSettings;
          };
        };

        programs = import ../shared/home-manager.nix { inherit lib pkgs; };
        manual.manpages.enable = false;
      };
  };

  local.dock = {
    enable = true;
    username = loginUser;
    entries = [
      { path = "/System/Applications/System Settings.app/"; }
      # { path = "/System/Applications/Notes.app/"; }
      # { path = "/System/Applications/Utilities/Terminal.app/"; }
      { path = "/Applications/Zen.app/"; }
      { path = "/Applications/WezTerm.app/"; }
      {
        path = "${config.users.users.${loginUser}.home}/Downloads";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
    ];
  };
}
