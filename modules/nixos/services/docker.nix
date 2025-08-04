{ config, lib, pkgs, ... }:

{
  virtualisation.docker = {
    enable = lib.mkDefault false;
    
    # Docker daemon settings
    daemon.settings = {
      # Enable experimental features
      experimental = true;
      # Set storage driver
      storage-driver = "overlay2";
      # Logging
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
    
    # Auto prune old images and containers
    autoPrune = {
      enable = true;
      flags = [ "--all" "--volumes" ];
      dates = "weekly";
    };
  };
  
  # Docker compose
  environment.systemPackages = lib.mkIf config.virtualisation.docker.enable [
    pkgs.docker-compose
  ];
}