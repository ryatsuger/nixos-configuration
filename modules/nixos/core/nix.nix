{ config, lib, pkgs, ... }:

{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      
      # Trusted users for remote builds
      trusted-users = [ "root" "@wheel" ];
      
      # Binary cache settings
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
    
    # Store optimization (replaces auto-optimise-store)
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
  
  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };
  
  # System packages list tracking
  environment.etc."current-system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;
  
  # Enable nix-ld for running unpatched binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Add any libraries your binaries need
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
    ];
  };
  
  # Enable automatic system updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;  # Don't auto-reboot
    # channel = "https://nixos.org/channels/nixos-25.05";
    dates = "daily";
    operation = "switch";  # or "boot" to apply on next boot
    flake = "${config.users.users.${config.mySystem.username}.home}/.config/nixos#${config.networking.hostName}";
  };
}
