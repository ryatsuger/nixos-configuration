{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # GCE image module
    "${modulesPath}/virtualisation/google-compute-image.nix"
    # Desktop profile
    ../../profiles/desktop.nix
    
    # Server profile
    # ../../profiles/server.nix
    
    ../../local.nix
  ];

  # Network configuration
  networking.hostName = "gce";
  mySystem.headless = true;
  
  # GCE-specific optimizations
  boot.kernelParams = [ "console=ttyS0" "panic=1" "boot.panic_on_fail" ];
  
  # Google guest agent is included in the GCE module
  security.googleOsLogin.enable = lib.mkForce false;
  
  # GCE requires firewall to be disabled (handled by cloud firewall)
  # Override the server profile's default
  networking.firewall.enable = lib.mkForce false;
  
  # Install gcloud SDK for GCE management
  environment.systemPackages = with pkgs; [
    google-cloud-sdk
  ];
  
  # GCE expects prohibit-password for root login
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
  
  # Enable VNC server for remote desktop access
  # VNC is configured for localhost-only access for security.
  # Use SSH tunneling to connect: ssh -L 5901:localhost:5901 user@gce-instance
  services.vncServer = {
    enable = true;
    
    # Security configuration for GCE - SSH tunnel access only
    localhostOnly = true;  # Secure: only accessible via SSH tunnel
    openFirewall = false;  # Don't open NixOS firewall (not needed for localhost)
    
    # Display configuration - optimized for poor network
    display = 1;
    port = 5901;
    geometry = "1920x1080";  # Full HD resolution
    depth = 16;  # 16-bit color uses less bandwidth than 24-bit
    
    # Performance optimizations
    compression = 9;  # Maximum compression (0-9)
    quality = 3;      # Lower quality for faster performance (0-9)
    
    # Password will be set manually by user with vncpasswd command
    # passwordFile = "/path/to/password/file";  # Optional: use existing password file
  };
  
  # VNC Setup Instructions:
  # 1. Set VNC password after first boot:
  #    vncpasswd  # This will prompt for password and save to ~/.vnc/passwd
  #
  # 2. Create GCE instance:
  #    gcloud compute instances create nixos-vnc \
  #      --image-family=nixos-25-05 \
  #      --image-project=nixos-cloud \
  #      --machine-type=e2-medium \
  #      --zone=us-central1-a \
  #      --metadata=enable-oslogin=FALSE
  #
  # 3. SSH to the instance with port forwarding:
  #    gcloud compute ssh nixos-vnc \
  #      --zone=us-central1-a \
  #      -- -L 5901:localhost:5901
  #
  # 4. Connect VNC viewer to: localhost:5901
  #
  # Alternative SSH tunnel from non-gcloud SSH:
  #    ssh -L 5901:localhost:5901 user@<external-ip>
  #
  # Note: No firewall rules needed - VNC is only accessible via SSH tunnel
}
