{ config, pkgs, ... }:

let
  lockSeconds = 300;
  offSeconds = 600;
  locker = "${pkgs.xsecurelock}/bin/xsecurelock";

  xidleScript = pkgs.writeShellScript "xidlehook-run" ''
    #!/usr/bin/env bash
    set -euo pipefail
    export DISPLAY=''${DISPLAY:-:0}
    export XAUTHORITY=''${XAUTHORITY:-$HOME/.Xauthority}
    
    # Use simple blank screensaver to avoid GPU/animation issues
    export XSECURELOCK_SAVER=saver_blank
    
    # Disable xscreensaver animations that might cause hangs
    # export XSECURELOCK_SAVER=saver_xscreensaver
    # export XSECURELOCK_SAVER_XSCREENSAVER_HACK=flurry

    # Disable compositor fade-out to prevent conflicts
    export XSECURELOCK_NO_COMPOSITE=1
    
    # Enable debug logging (uncomment to debug)
    # export XSECURELOCK_DEBUG=1

    # Ensure DPMS enabled; disable legacy X screensaver
    xset +dpms
    xset s off

    exec ${pkgs.xidlehook}/bin/xidlehook \
      --not-when-fullscreen \
      --not-when-audio \
      --timer ${toString lockSeconds} \
        "${locker}" \
        "" \
      --timer ${toString offSeconds} \
        "xset dpms force off" \
        ""
  '';
in {
  home.packages = [ 
    pkgs.xidlehook 
    pkgs.xsecurelock 
    pkgs.xorg.xset 
    pkgs.xscreensaver 
  ];

  systemd.user.services.xidlehook = {
    Unit = {
      Description = "Idle lock + DPMS (xidlehook wrapper)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = xidleScript;
      Restart = "on-failure";
      RestartSec = 2;
      # Optional debugging:
      # Environment = "XSECURELOCK_DEBUG=1"
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
