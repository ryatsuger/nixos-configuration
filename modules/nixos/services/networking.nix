{ config, lib, pkgs, ... }:

{
  # SSH configuration
  services.openssh = {
    enable = lib.mkDefault true;
    allowSFTP = true;
    settings = {
      X11Forwarding = lib.mkDefault false;
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
      UseDns = lib.mkDefault false;
      MaxAuthTries = lib.mkDefault 3;
    };
    extraConfig = ''
      PrintLastLog no
      ClientAliveInterval 300
      ClientAliveCountMax 2
    '';
  };
  
  # Tailscale VPN
  services.tailscale = {
    enable = lib.mkDefault false;
    useRoutingFeatures = lib.mkDefault "client";
    interfaceName = "tailscale0";
  };
  
  # Additional firewall rules for services
  networking.firewall = lib.mkIf config.services.tailscale.enable {
    # Tailscale requires UDP port
    allowedUDPPorts = [ 41641 ];
    # Enable IP forwarding for exit node functionality
    checkReversePath = "loose";
  };
}