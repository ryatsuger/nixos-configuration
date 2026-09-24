{ config, lib, pkgs, osConfig, ... }:

let
  isHeadless = osConfig.mySystem.headless or false;
in
{
  programs.ssh = {
    enable = true;
    # Opt out of home-manager's legacy default `Host *` block; we define our
    # own defaults under settings."*" below.
    enableDefaultConfig = false;

    settings = {
      # Global settings for all hosts
      "*" = {
        # Security settings
        HashKnownHosts = true;
        StrictHostKeyChecking = "ask";
        VerifyHostKeyDNS = "yes";

        # Connection settings
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%h:%p";
        ControlPersist = "10m";
      } // lib.optionalAttrs (!isHeadless) {
        # 1Password agent (desktop only)
        IdentityAgent = "~/.1password/agent.sock";
      };

      # GitHub is reached with several different keys from this box (four are
      # loaded: ruiyangke, ryatsuger, rieonke, RYKE), and ControlPath has no
      # token for the identity -- %r@%h:%p collapses to a single socket for all
      # of github.com. The first connection wins and pins its account for
      # ControlPersist, after which every `-i` is silently ignored: a push as
      # ruiyangke reuses a ryatsuger master and fails with "Repository not
      # found", which reads as a permissions problem and is not one.
      #
      # There is no ControlPath token for the key, so the sockets cannot be
      # separated; multiplexing has to go for this host. The cost is one TCP
      # and one handshake per git operation.
      "github.com" = {
        ControlMaster = "no";
      };

      # AWS instances via Session Manager
      "i-*" = {
        ProxyCommand = "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
        User = "ec2-user";
        IdentityFile = "~/.ssh/id_ed25519_aws";
      };
    };
  };

  # Use 1Password SSH agent on non-headless machines
  # Headless machines rely on SSH agent forwarding
  home.sessionVariables = lib.mkIf (!isHeadless) {
    SSH_AUTH_SOCK = "~/.1password/agent.sock";
  };
}
