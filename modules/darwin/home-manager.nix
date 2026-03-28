{
  config,
  pkgs,
  lib,
  zen-browser,
  ...
}:

let
  loginUser = "kimbank";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { user = loginUser; inherit config pkgs; };
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
    casks = pkgs.callPackage ./casks.nix { };
    masApps = { };
  };

  home-manager = {
    useGlobalPkgs = true;

    users.${loginUser} =
      { pkgs, config, lib, ... }:
      {
        imports = [ zen-browser.homeModules.twilight ];

        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
          ];
          stateVersion = "24.11";
        };

        programs =
          (import ../shared/home-manager.nix { inherit lib; })
          // {
            "zen-browser" = {
              enable = true;
              nativeMessagingHosts = [ pkgs._1password-gui ];
              policies.ExtensionSettings = {
                "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
                  install_url =
                    "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
                  installation_mode = "force_installed";
                };
              };
            };
          };
        manual.manpages.enable = false;
      };
  };

  local.dock = {
    enable = true;
    username = loginUser;
    entries = [
      { path = "/System/Applications/Safari.app/"; }
      { path = "/System/Applications/Notes.app/"; }
      { path = "/System/Applications/Utilities/Terminal.app/"; }
      { path = "/System/Applications/System Settings.app/"; }
      {
        path = "${config.users.users.${loginUser}.home}/Downloads";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
    ];
  };
}
