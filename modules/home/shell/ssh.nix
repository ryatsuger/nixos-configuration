{ config, lib, pkgs, osConfig, ... }:

let
  isHeadless = osConfig.mySystem.headless or false;
in
{
  programs.ssh = {
    enable = true;

    # SSH client configuration
    extraConfig = ''
      # Global settings for all hosts
      Host *
    '' + lib.optionalString (!isHeadless) ''
        # 1Password agent (desktop only)
        IdentityAgent ~/.1password/agent.sock
    '' + ''
        # Security settings
        HashKnownHosts yes
        StrictHostKeyChecking ask
        VerifyHostKeyDNS yes

        # Connection settings
        ServerAliveInterval 60
        ServerAliveCountMax 3
        ControlMaster auto
        ControlPath ~/.ssh/master-%r@%h:%p
        ControlPersist 10m
    '';

    # Host-specific configurations
    matchBlocks = {
      # AWS instances via Session Manager
      "i-*" = {
        proxyCommand = "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
        user = "ec2-user";
        identityFile = "~/.ssh/id_ed25519_aws";
      };
    };
  };

  # Use 1Password SSH agent on non-headless machines
  # Headless machines rely on SSH agent forwarding
  home.sessionVariables = lib.mkIf (!isHeadless) {
    SSH_AUTH_SOCK = "~/.1password/agent.sock";
  };
}
