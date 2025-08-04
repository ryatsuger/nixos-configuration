{ config, lib, pkgs, ... }:

{
  # DNS configuration
  networking = {
    # Use Cloudflare DNS by default
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    
    # Firewall configuration
    # Note: firewall.enable is not set here to avoid conflicts with cloud images
    # Each profile/host should set it explicitly if needed
    firewall = {
      # Common ports
      allowedTCPPorts = lib.mkDefault [ 
        22   # SSH
        80   # HTTP
        443  # HTTPS
      ];
      
      # Development port ranges
      allowedTCPPortRanges = lib.mkDefault [
        { from = 3000; to = 9000; }
      ];
      allowedUDPPortRanges = lib.mkDefault [
        { from = 3000; to = 9000; }
      ];
    };
  };
  
  # Time synchronization
  services.timesyncd.enable = lib.mkDefault true;
  
  # Network manager for desktop systems
  # (will be enabled by desktop profile)
  networking.networkmanager.enable = lib.mkDefault false;
}