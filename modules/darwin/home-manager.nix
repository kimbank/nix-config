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
      in
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
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

        targets.darwin = {
          copyApps.enable = true;
          linkApps.enable = false;
          defaults = {
            NSGlobalDomain."com.apple.mouse.tapBehavior" = 0;
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
            # Manage colima.yaml declaratively so the default profile comes up
            # with k3s enabled for local manifest and deployment testing.
            # Home Manager starts managed profiles with --save-config=false, so
            # Colima will not try to rewrite this generated YAML.
            settings.kubernetes = {
              enabled = true;
              k3sArgs = [ "--disable=traefik" ];
            };
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
