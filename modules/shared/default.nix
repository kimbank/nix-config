{ ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };

    overlays =
      let
        path = ../../overlays;
      in
      with builtins;
      map (name: import (path + ("/" + name))) (
        filter (
          name:
          match ".*\\.nix" name != null || pathExists (path + ("/" + name + "/default.nix"))
        ) (attrNames (readDir path))
      );
  };
}
