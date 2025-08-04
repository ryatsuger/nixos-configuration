{ config, lib, pkgs, ... }:

{
  imports = [
    # Include base profile
    ./base.nix
    
    # Desktop modules (includes default.nix which imports fonts, i18n, and x11)
    ../modules/nixos/desktop/default.nix
    
    # X11 display server
    ../modules/nixos/desktop/x11.nix
    
    # Optional services for desktop
    ../modules/nixos/services/docker.nix
    ../modules/nixos/services/vnc.nix
  ];
  
  # Enable desktop
  mySystem.enableDesktop = true;
  
  # Enable firewall for desktop systems
  networking.firewall.enable = lib.mkDefault true;
  
  # Enable Docker for development
  virtualisation.docker.enable = true;
}