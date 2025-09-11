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

  # Set console resolution to 2560x1600
  boot.loader.systemd-boot.consoleMode = "max";
  boot.kernelParams = [ "video=2560x1600" ];

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

  # Set display resolution to 2560x1600
  services.xserver.resolutions = [{
    x = 2560;
    y = 1600;
  }];

  # ARM64 platform
  nixpkgs.hostPlatform = "aarch64-linux";

  # VMware tools and shared folders
  virtualisation.vmware.guest.enable = true;

  # Auto-mount VMware shared folders
  fileSystems."/mnt/hgfs" = {
    device = ".host:/";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options =
      [ "uid=1000" "gid=100" "umask=022" "allow_other" "defaults" "auto" ];
  };

  # Create a symlink for easier access
  systemd.tmpfiles.rules = [ "L+ /home/ruiyang/VMShared - - - - /mnt/hgfs" ];

  # Cloudflare Tunnel configuration
  services.cloudflared = {
    enable = true;

    # Using tunnel token (connector) - simpler setup
    tunnels = {
      "530689a8-4dd8-4bdf-bc8a-2bd29a755e2f" = {
        # Token-based authentication
        credentialsFile = "/etc/cloudflared/tunnel-token";

        ingress = {
          # Services configured in Cloudflare dashboard:
          # dev-ry.suger.dev -> localhost:3000

          # Additional services - uncomment and modify as needed:

          # Expose SSH (use with: cloudflared access ssh --hostname ssh-vmware.yourdomain.com)
          # "ssh-vmware.yourdomain.com" = "ssh://localhost:22";

          # Expose VNC
          # "vnc-vmware.yourdomain.com" = "tcp://localhost:5900";

          # Expose Home Assistant
          # "home.yourdomain.com" = "http://localhost:8123";
        };

        default = "http_status:404";
      };
    };
  };

  # Force HTTP/2 protocol for Cloudflare tunnel (VMware blocks QUIC/UDP)
  systemd.services."cloudflared-tunnel-530689a8-4dd8-4bdf-bc8a-2bd29a755e2f" = {
    environment = { TUNNEL_TRANSPORT_PROTOCOL = "http2"; };
  };

  # Install cloudflared CLI for tunnel management
  environment.systemPackages = with pkgs; [ cloudflared ];
}
