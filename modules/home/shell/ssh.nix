{ config, lib, pkgs, osConfig, ... }:

{
  programs.ssh = {
    enable = true;
    
    # SSH client configuration
    extraConfig = ''
      # Global settings for all hosts
      Host *
        # Try 1Password agent first, fallback to standard SSH agent
        IdentityAgent ~/.1password/agent.sock
        IdentityAgent ~/.ssh/agent.sock
        
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
      # Work-related hosts (example)
      # "*.company.com" = {
      #   user = osConfig.mySystem.username or "nixos";
      #   identityFile = "~/.ssh/id_ed25519_work";
      #   forwardAgent = true;
      # };
      
      # AWS instances via Session Manager
      "i-*" = {
        proxyCommand = "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
        user = "ec2-user";
        identityFile = "~/.ssh/id_ed25519_aws";
      };
    };
  };
  
  # SSH agent systemd service
  systemd.user.services.ssh-agent = {
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
  
  # Set SSH_AUTH_SOCK for all sessions
  home.sessionVariables = {
    SSH_AUTH_SOCK = lib.mkIf (!config.programs._1password-gui.enable or false) 
      "\${XDG_RUNTIME_DIR}/ssh-agent.socket";
  };
}
