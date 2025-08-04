{ config, lib, pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./i18n.nix
  ];

  config = lib.mkIf config.mySystem.enableDesktop {
    # Desktop packages
    environment.systemPackages = with pkgs; [
      chromium
      firefox
      
      # GUI utilities
      xclip
      xsel
      
      # File managers
      pcmanfm
      
      # Image viewers
      feh
      
      # PDF viewers
      zathura
      
      # VNC client
      tigervnc
    ];

    # 1Password GUI
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ config.mySystem.username ];
    };
    
    # Enable dconf for GTK apps
    programs.dconf.enable = true;
    
    # Enable network manager for desktop
    networking.networkmanager.enable = true;
    
    # Sound
    services.pulseaudio.enable = lib.mkDefault false;
    services.pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
    # GUI environment variables
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GDK_SCALE = "1";
      GDK_DPI_SCALE = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_SCALE_FACTOR = "1";
    };
  };
}