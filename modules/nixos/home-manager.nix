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
  users.users.${loginUser} = {
    isNormalUser = true;
    description = "Kimbank";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
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

        programs = import ../shared/home-manager.nix { inherit lib pkgs; };
        manual.manpages.enable = false;
      };
  };
}
