{ config, lib, pkgs, osConfig, ... }:

let
  has1PasswordGui = osConfig.programs._1password-gui.enable or false;
in
{
  programs.ssh = {
    enable = true;

    # SSH client configuration
    extraConfig = ''
      # Global settings for all hosts
      Host *
    '' + lib.optionalString has1PasswordGui ''
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

  # SSH agent systemd service (desktop only, headless uses agent forwarding)
  systemd.user.services.ssh-agent = lib.mkIf has1PasswordGui {
    Unit = {
      Description = "SSH Agent";
      Documentation = "man:ssh-agent(1)";
    };

    Service = {
      Type = "forking";
      Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -a %t/ssh-agent.socket";
      ExecStop = "${pkgs.openssh}/bin/ssh-agent -k";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Set SSH_AUTH_SOCK only on desktop (headless gets it from agent forwarding)
  home.sessionVariables = lib.mkIf has1PasswordGui {
    SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/ssh-agent.socket";
  };
}
