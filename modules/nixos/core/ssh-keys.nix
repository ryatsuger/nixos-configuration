{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.mySystem.ssh;
in
{
  options.mySystem.ssh = {
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "SSH public keys to authorize for the main user";
      example = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... user@host"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... user@host"
      ];
    };
    
    hostKeys = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to generate persistent host keys";
      };
      
      path = mkOption {
        type = types.str;
        default = "/etc/ssh";
        description = "Path to store host keys";
      };
    };
    
    knownHosts = mkOption {
      type = types.attrs;
      default = {};
      description = "Known SSH hosts in NixOS format";
      example = literalExpression ''
        {
          "github.com" = {
            hostNames = [ "github.com" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          };
        }
      '';
    };
  };

  config = {
    # Configure authorized keys for the main user
    users.users.${config.mySystem.username}.openssh.authorizedKeys.keys = cfg.authorizedKeys;
    
    # Configure SSH known hosts
    programs.ssh.knownHosts = cfg.knownHosts;
    
    # Ensure SSH host keys persist across rebuilds
    services.openssh.hostKeys = mkIf cfg.hostKeys.enable [
      {
        path = "${cfg.hostKeys.path}/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
      {
        path = "${cfg.hostKeys.path}/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}