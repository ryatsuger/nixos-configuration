{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix
    
    # Desktop profile
    ../../profiles/desktop.nix

    ../../local.nix
  ]; 

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Network configuration
  networking.hostName = "vmware";
  
  # Disable NetworkManager (from desktop profile) and use systemd-networkd instead
  networking.networkmanager.enable = lib.mkForce false;
  
  # Enable systemd-networkd
  systemd.network.enable = true;
  networking.useNetworkd = true;
  
  # Basic DHCP configuration for all interfaces
  systemd.network.networks."10-dhcp" = {
    matchConfig.Name = "en*";
    networkConfig = {
      DHCP = "yes";
      DNSSEC = "allow-downgrade";
      DNSOverTLS = "opportunistic";
    };
    dhcpV4Config = {
      RouteMetric = 100;
      UseDNS = true;
    };
  };
  
  # Higher DPI for retina displays
  services.xserver.dpi = 144;
  
  # ARM64 platform
  nixpkgs.hostPlatform = "aarch64-linux";
  
  # VMware tools and shared folders
  virtualisation.vmware.guest.enable = true;
  
  # Auto-mount VMware shared folders
  fileSystems."/mnt/hgfs" = {
    device = ".host:/";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [
      "uid=1000"
      "gid=100"
      "umask=022"
      "allow_other"
      "defaults"
      "auto"
    ];
  };
  
  # Create a symlink for easier access
  systemd.tmpfiles.rules = [
    "L+ /home/ruiyang/VMShared - - - - /mnt/hgfs"
  ];
}
