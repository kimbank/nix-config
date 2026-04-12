{ pkgs }:

with pkgs; [
  # Local EAS iOS builds shell out to fastlane on macOS.
  fastlane
  mas
]
