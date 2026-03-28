{
  config,
  pkgs,
  lib,
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
        };

        programs = import ../shared/home-manager.nix { inherit lib; };
        manual.manpages.enable = false;
      };
  };

  local.dock = {
    enable = true;
    username = loginUser;
    entries = [
      { path = "/System/Applications/Zen.app/"; }
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
