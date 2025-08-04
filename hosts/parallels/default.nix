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
  
  # Disable GRUB for EFI
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = false;

  # Parallels-specific kernel modules
  boot.kernelModules = [ "prl_fs" "prl_tg" "prl_eth" ];
  
  # Network configuration
  networking.hostName = "nixos-parallels-m4";
  
  # Higher DPI for retina displays
  services.xserver.dpi = 144;
  
  # ARM64 platform
  nixpkgs.hostPlatform = "aarch64-linux";
}
