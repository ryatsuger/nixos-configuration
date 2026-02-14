{ config, lib, pkgs, ... }:

{
  # SSH configuration
  services.openssh = {
    enable = lib.mkDefault true;
    allowSFTP = true;
    settings = {
      X11Forwarding = lib.mkDefault false;
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
      UseDns = lib.mkDefault false;
      MaxAuthTries = lib.mkDefault 3;
    };
    extraConfig = ''
      PrintLastLog no
      ClientAliveInterval 300
      ClientAliveCountMax 2
    '';
  };
}
