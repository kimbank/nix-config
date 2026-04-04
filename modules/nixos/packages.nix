{ pkgs, ... }:

with pkgs; [
  # Linux specific packages
  wl-clipboard
  wayland-utils
  lm_sensors
  btop
]
