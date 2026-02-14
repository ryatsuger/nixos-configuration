{ config, lib, pkgs, osConfig, ... }:

{
  services.picom = {
    enable = true;

    # Use xrender backend for better VM compatibility
    backend = "xrender";

    # Vsync to prevent tearing
    vSync = true;

    # No shadows (keep it simple for DWM)
    shadow = false;

    # No fading (can cause issues in VMs)
    fade = false;

    # No inactive dimming
    settings = {
      inactive-dim = 0;

      # Prevent flickering
      unredir-if-possible = false;

      # Use damage tracking for better performance
      use-damage = true;
    };
  };
}
