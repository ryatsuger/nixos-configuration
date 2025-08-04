{ config, lib, pkgs, ... }:

{
  imports = [
    # Core system modules
    ../modules/nixos/core/nix.nix
    ../modules/nixos/core/networking.nix
    ../modules/nixos/core/users.nix
    ../modules/nixos/core/packages.nix
    ../modules/nixos/core/locale.nix
    ../modules/nixos/core/ssh-keys.nix
    ../modules/nixos/core/debug-users.nix
    
    # Essential services
    ../modules/nixos/services/networking.nix
    ../modules/nixos/services/security.nix
    
    # Options
    ../modules/nixos/options.nix
  ];
  
  # Base system configuration
  system.stateVersion = lib.mkDefault "25.05";
}