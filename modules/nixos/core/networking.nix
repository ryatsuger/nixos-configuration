{ config, lib, pkgs, ... }:

{
  # DNS configuration
  networking = {
    # Firewall configuration
    # Note: firewall.enable is not set here to avoid conflicts with cloud images
    # Each profile/host should set it explicitly if needed
    firewall = {
      # Common ports
      allowedTCPPorts = lib.mkDefault [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];

      # Development port ranges
      allowedTCPPortRanges = lib.mkDefault [{
        from = 3000;
        to = 9000;
      }];
      allowedUDPPortRanges = lib.mkDefault [{
        from = 3000;
        to = 9000;
      }];
    };
  };

  # Time synchronization
  services.timesyncd.enable = lib.mkDefault true;

  # Network manager for desktop systems
  # (will be enabled by desktop profile)
  networking.networkmanager.enable = lib.mkDefault false;

  # Enable systemd-resolved for DNS resolution
  services.resolved = {
    enable = true;
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    dnssec = "false"; # Disable DNSSEC completely to fix resolution issues
    extraConfig = ''
      DNS=1.1.1.1 8.8.8.8
      DNSOverTLS=no
      DNSSEC=no
    '';
  };

  # Use systemd-resolved stub resolver
  networking.nameservers = [ "127.0.0.53" ];
}
