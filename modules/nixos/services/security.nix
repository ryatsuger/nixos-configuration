{ config, lib, pkgs, ... }:

{
  # Fail2ban for SSH protection
  services.fail2ban = {
    enable = lib.mkDefault true;
    maxretry = 5;
    ignoreIP = [ "127.0.0.0/8" "::1" ];
    bantime = "10m";
    bantime-increment = {
      enable = true;
      rndtime = "5m";
      maxtime = "24h";
      factor = "2";
    };
    # In NixOS 25.05, jails are configured differently
    # The sshd jail is enabled by default when fail2ban and openssh are enabled
  };
  
  # Security hardening
  security = {
    # Enable AppArmor
    apparmor.enable = lib.mkDefault true;
    
    # Kernel hardening
    protectKernelImage = true;
    
    # Polkit for privilege escalation
    polkit.enable = true;
  };
  
  # Kernel parameters for security
  boot.kernel.sysctl = {
    # Kernel hardening
    "kernel.yama.ptrace_scope" = 2;
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.printk" = "3 3 3 3";
    
    # Network hardening
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };
  
  # Common programs
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  
  # 1Password CLI
  programs._1password.enable = true;
}