{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # AWS EC2 image module
    "${modulesPath}/virtualisation/amazon-image.nix"
    
    # Server profile
    ../../profiles/server.nix

    ../../local.nix
  ];

  # EC2-specific configuration
  ec2.hvm = true;
  
  # Network configuration
  networking.hostName = "nixos-aws";
  
  # AWS-optimized kernel parameters
  boot.kernelParams = [ "console=ttyS0" ];
  
  # Enable SSM agent for AWS Systems Manager
  services.amazon-ssm-agent.enable = true;
  
  # CloudWatch agent (optional)
  # services.amazon-cloudwatch-agent.enable = true;
  
  # AWS expects prohibit-password for root login
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
}
