{ config, lib, pkgs, ... }:

{
  imports = [
    # Include base profile
    ./base.nix
  ];
  
  # Server-specific settings
  mySystem.enableDesktop = false;
  
  # Enable firewall for server systems (unless overridden by cloud platform)
  networking.firewall.enable = lib.mkDefault true;
  
  # Disable GUI
  services.xserver.enable = false;
  
  # Additional server packages
  environment.systemPackages = with pkgs; [
    # Monitoring tools
    btop
    iotop
    
    # Cloud tools
    kubectl
    
    # Server management
    rsync
    screen
  ];
}