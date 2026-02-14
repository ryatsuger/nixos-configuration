{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.mySystem.enableDesktop {
    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Hyprland-specific packages
    environment.systemPackages = with pkgs; [
      wl-clipboard
      wl-clip-persist
      wlr-randr
      hyprpaper
      hypridle
      hyprlock
      fuzzel
      waybar
      grim
      slurp
      swappy
    ];

    # PAM for hyprlock
    security.pam.services.hyprlock = {};

    # Environment variables for Wayland/VM compatibility
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      WLR_DRM_NO_ATOMIC = "1";
      LIBGL_ALWAYS_SOFTWARE = "0";
      XCURSOR_SIZE = "16";
    };
  };
}
