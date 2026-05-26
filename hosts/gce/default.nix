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
  networking.enableIPv6 = false;
  mySystem.headless = true;
  
  # GCE-specific optimizations
  boot.kernelParams = [ "console=ttyS0" "panic=1" "boot.panic_on_fail" ];

  # KVM nested virtualization (requires --enable-nested-virtualization on GCE instance)
  boot.kernelModules = [ "kvm-amd" ];
  
  # Google guest agent is included in the GCE module
  security.googleOsLogin.enable = lib.mkForce false;
  
  # GCE requires firewall to be disabled (handled by cloud firewall)
  # Override the server profile's default
  networking.firewall.enable = lib.mkForce false;
  
  # Install gcloud SDK for GCE management
  environment.systemPackages = with pkgs; [
    google-cloud-sdk
    azure-cli
  ];
  
  # GCE expects prohibit-password for root login
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
}
