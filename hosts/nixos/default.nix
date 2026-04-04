{ config, lib, pkgs, modulesPath, ... }:

let
  loginUser = "kimbank";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/nixos/home-manager.nix
    ../../modules/shared
  ];

  # Hardware Configuration (minimal default structure)
  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    loader.efi.canTouchEfiVariables = true;
  };

  # Filesystem defaults (Placeholder, update device for actual install)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Hardware platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  time.timeZone = "Asia/Seoul";

  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    zsh.enable = true;
    _1password.enable = true;
    _1password-gui.enable = true;
  };

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        options = "ctrl:nocaps";
      };
    };

    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    openssh.enable = true;
  };

  # Docker
  virtualisation.docker.enable = true;

  nix = {
    package = pkgs.nix;

    settings = {
      trusted-users = [
        "@admin"
        "${loginUser}"
        "root"
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
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  environment.systemPackages = import ../../modules/shared/packages.nix { inherit pkgs; } ++ [
    pkgs.vim
    pkgs.git
  ];

  fonts.packages = [
    pkgs.jetbrains-mono
  ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  system.stateVersion = "24.11";
}
