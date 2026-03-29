{ pkgs, ... }:

let
  loginUser = "kimbank";
in
{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
  ];

  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  nix = {
    package = pkgs.nix;

    settings = {
      trusted-users = [
        "@admin"
        "${loginUser}"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [ "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 14d";
    };
  };

  environment.systemPackages = import ../../modules/shared/packages.nix { inherit pkgs; };

  power.sleep.display = 60;

  system = {
    checks.verifyNixPath = false;
    primaryUser = loginUser;
    stateVersion = 5;

    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        "com.apple.sound.beep.volume" = 0.0;
      };

      dock = {
        autohide = true;
        show-recents = false;
        orientation = "bottom";
        tilesize = 40;
      };

      controlcenter = {
        BatteryShowPercentage = false;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
      };

      menuExtraClock = {
        IsAnalog = true;
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 2;
        ShowDayOfMonth = false;
        ShowDayOfWeek = false;
        ShowSeconds = false;
      };

      trackpad = {
        Clicking = false;
        TrackpadThreeFingerDrag = true;
      };

      universalaccess = {
        closeViewScrollWheelToggle = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
