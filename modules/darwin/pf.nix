{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.local.vncFirewall;

  # Keep the VNC rules in a dedicated anchor so we only touch the Screen
  # Sharing port and leave the rest of the PF policy alone.
  anchorName = "org.nixos.vnc-screen-sharing";
  anchorPath = "/etc/pf.anchors/${anchorName}";
  rulesPath = "/etc/pf-vnc-screen-sharing.conf";

  allowedNetworks = concatStringsSep ", " cfg.allowedCidrs;
  protectedPorts = concatStringsSep ", " (map toString cfg.ports);

  applyPfRules = ''
    # Fail fast on invalid PF syntax before reloading the live ruleset.
    /sbin/pfctl -vnf ${rulesPath}
    # Enabling PF is harmless when it is already on. macOS keeps a reference
    # count internally, so this only ensures PF is active before loading rules.
    /sbin/pfctl -e 2>/dev/null || true
    exec /sbin/pfctl -f ${rulesPath}
  '';
in
{
  options.local.vncFirewall = {
    enable = mkEnableOption "pf-based Screen Sharing/VNC allowlist";

    allowedCidrs = mkOption {
      type = with types; listOf str;
      default = [ "100.0.0.0/8" ];
      description = ''
        Trusted networks that may reach the protected VNC ports. The default
        keeps the allowlist broad across tailnet-assigned IPv4 addresses.
      '';
    };

    ports = mkOption {
      type = with types; listOf ints.unsigned;
      default = [ 5900 ];
      description = ''
        TCP ports to restrict with PF. The default is the Screen Sharing/VNC
        port used by macOS.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.etc."pf.anchors/${anchorName}".text = ''
      # `allowedCidrs` is the only allowlist knob. There is no MAC-address
      # filtering here; PF matches inbound packets by network attributes.
      table <trusted_vnc_clients> const { ${allowedNetworks} }

      # Only the macOS Screen Sharing / VNC port is filtered here.
      pass in quick proto tcp from <trusted_vnc_clients> to any port { ${protectedPorts} }
      block drop in quick proto tcp from any to any port { ${protectedPorts} }
    '';

    environment.etc."pf-vnc-screen-sharing.conf".text = ''
      # Preserve Apple's anchor chain so built-in PF consumers keep working.
      scrub-anchor "com.apple/*"
      nat-anchor "com.apple/*"
      rdr-anchor "com.apple/*"
      dummynet-anchor "com.apple/*"
      anchor "com.apple/*"
      load anchor "com.apple" from "/etc/pf.anchors/com.apple"

      # `pfctl -sr` on the main ruleset will usually show only this anchor
      # reference. Inspect the actual VNC rules with:
      #   sudo pfctl -a ${anchorName} -sr
      anchor "${anchorName}"
      load anchor "${anchorName}" from "${anchorPath}"
    '';

    launchd.daemons.pf-vnc-screen-sharing = {
      script = applyPfRules;
      serviceConfig = {
        RunAtLoad = true;
        WatchPaths = [
          rulesPath
          anchorPath
        ];
      };
    };
  };
}
