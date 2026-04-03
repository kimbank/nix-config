{
  config,
  pkgs,
  lib,
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
    brews = [ "opencode" ];
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
        sharedFiles = import ../shared/files.nix { inherit config; };
      in
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
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
            # Keep profile settings empty here so Home Manager does not
            # manage ~/.colima/default/colima.yaml as an immutable symlink.
            # Colima rewrites that file during startup.
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
