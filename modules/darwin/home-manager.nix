{
  config,
  pkgs,
  lib,
  ...
}:

let
  loginUser = "kimbank";
  bravePolicies = {
    TranslateEnabled = false;
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "Brave Search";
    DefaultSearchProviderSearchURL = "https://search.brave.com/search?q={searchTerms}";
    DefaultSearchProviderSuggestURL = "https://search.brave.com/api/suggest?q={searchTerms}&rich=true&source=desktop";
  };
  bravePolicyPlist = pkgs.formats.plist { }.generate "com.brave.Browser.plist" bravePolicies;
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

  system.activationScripts.braveManagedPolicies.text = ''
    install -d -m 0755 "/Library/Managed Preferences"
    install -m 0644 ${bravePolicyPlist} "/Library/Managed Preferences/com.brave.Browser.plist"
  '';

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
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

        home.activation.clearBraveUserDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          for domain in com.brave.Browser com.brave.browser; do
            run /usr/bin/defaults delete "$domain" TranslateEnabled || true
            run /usr/bin/defaults delete "$domain" DefaultSearchProviderEnabled || true
            run /usr/bin/defaults delete "$domain" DefaultSearchProviderName || true
            run /usr/bin/defaults delete "$domain" DefaultSearchProviderSearchURL || true
            run /usr/bin/defaults delete "$domain" DefaultSearchProviderSuggestURL || true
          done
        '';

        targets.darwin = {
          copyApps.enable = true;
          linkApps.enable = false;
          defaults = {
            NSGlobalDomain."com.apple.mouse.tapBehavior" = 0;
          };
          currentHostDefaults = {
            NSGlobalDomain."com.apple.mouse.tapBehavior" = 0;
            "com.apple.screensaver".idleTime = 0;
          };
        };

        services.colima = {
          enable = true;
          profiles.default = {
            isActive = true;
            isService = true;
            setDockerHost = true;
            settings.runtime = "docker";
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
