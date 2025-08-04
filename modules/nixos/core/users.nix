{ config, lib, pkgs, ... }:

{
  # User configuration
  users.users.${config.mySystem.username} = {
    isNormalUser = true;
    description = config.mySystem.userFullName;
    extraGroups = [ "wheel" ] 
      ++ lib.optional config.virtualisation.docker.enable "docker"
      ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = false;

  
  # Enable zsh system-wide
  programs.zsh.enable = true;
}
