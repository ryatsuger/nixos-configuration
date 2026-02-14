{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix

    # Desktop profile
    ../../profiles/desktop.nix

    ../../local.nix
  ];

  # Boot configuration for ARM64 Parallels
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set console resolution to 2560x1600
  boot.loader.systemd-boot.consoleMode = "max";
  boot.kernelParams = [
    "video=2560x1600"
    "video=Virtual-1:2560x1600@60e"
    "prl_vid.mode=2560x1600"
  ];

  # Disable GRUB for EFI
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  # Clean /tmp on boot to prevent disk space buildup
  boot.tmp.cleanOnBoot = true;

  # Parallels-specific kernel modules
  boot.kernelModules = [ "prl_fs" "prl_tg" "prl_eth" ];
  
  # Enable Parallels Tools
  hardware.parallels.enable = true;

  # Network configuration
  networking.hostName = "parallels";
  
  # Local development hosts
  networking.hosts = {
    "127.0.0.1" = [ 
      "local.cosell.us"           # Root domain
      "tenant1.local.cosell.us"   # Example tenant 1
      "tenant2.local.cosell.us"   # Example tenant 2
      "tenant3.local.cosell.us"   # Example tenant 3
      "demo.local.cosell.us"      # Demo tenant
      "test.local.cosell.us"      # Test tenant
    ];
  };

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

  # Set display resolution to 2560x1600
  services.xserver.resolutions = [{
    x = 2560;
    y = 1600;
  }];

  # ARM64 platform
  nixpkgs.hostPlatform = "aarch64-linux";

  # Enable time synchronization (override Parallels default)
  services.timesyncd = {
    enable = lib.mkForce true;
    servers = [ "time.apple.com" "pool.ntp.org" ];
  };
  
  # Ensure systemd-networkd enables NTP
  systemd.network.networks."10-dhcp" = {
    dhcpV4Config.UseNTP = lib.mkForce true;
  };

  # Parallels clipboard sharing
  systemd.user.services.prlcp = {
    description = "Parallels Clipboard Sharing";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.prl-tools}/bin/prlcp";
      Restart = "always";
      RestartSec = "5";
    };
  };
}
