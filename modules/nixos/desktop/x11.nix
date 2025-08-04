{ pkgs, lib, ... }:

{
  services = {
    dbus.enable = true;
    gvfs.enable = true;
    libinput = {
      enable = true;
      touchpad = { naturalScrolling = true; };
    };
    touchegg.enable = true;
    xserver = {
      enable = true;

      # Reduce DPI for better GUI scaling
      dpi = lib.mkDefault 96;  # Standard DPI, was 192
      xkb = {
        variant = "";
        layout = "us";
        options = "caps:ctrl_modifier";
      };

      # Disable DPMS and screensaver to prevent dwm freezes
      serverFlagsSection = ''
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime" "0"
        Option "BlankTime" "0"
        Option "DPMS" "false"
      '';

      desktopManager = {
        runXdgAutostartIfNone = true;
        xterm.enable = false;
        xfce.enable = false;  # Not needed with dwm
      };

      windowManager = {
        stumpwm = { enable = false; };
        dwm = {
          enable = true;
          package = with pkgs;
            (dwm.overrideAttrs { }).override { patches = [ ./dwm.patch ]; };
        };
      };
      excludePackages = with pkgs; [ xterm ];
    };
  };

  services.displayManager = {
    ly.enable = true;
    defaultSession = "dwm";
  };

  # programs.thunar.enable = true;
  programs.dconf.enable = true;
  programs.light.enable = true;
  environment.systemPackages = with pkgs; [
    dmenu
    upower
    flameshot
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    
    # X utilities for preventing freezes
    xorg.xset
    xorg.xrandr
    xorg.xinit
    
    # DWM keepalive script
    (writeScriptBin "dwm-keepalive" ''
      #!/bin/sh
      # Prevent dwm from freezing by periodically triggering minimal X activity
      while true; do
        sleep 300  # Every 5 minutes
        xset q > /dev/null 2>&1 || exit 0
      done
    '')
  ];

  # Systemd service to prevent DWM freezing
  systemd.user.services.dwm-keepalive = {
    description = "DWM keepalive to prevent freezing";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash -c 'while true; do sleep 300; ${pkgs.xorg.xset}/bin/xset q > /dev/null 2>&1 || exit 0; done'";
      Restart = "always";
      RestartSec = "10";
    };
  };

}
