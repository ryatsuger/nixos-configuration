{ config, lib, pkgs, ... }:

{
  # Essential system packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    git
    git-lfs
    wget
    curl
    htop
    
    # File management
    ripgrep
    fd
    tree
    ncdu
    
    # Network tools
    inetutils
    dig
    netcat
    
    # System tools
    pciutils
    usbutils
    lsof
    
    # Archive tools
    unzip
    zip
    
    # Text processing
    jq
    yq
    
    # Nix tools
    nixfmt-classic
    nix-tree
    nix-diff
    
    # Development tools
    tmux
    docker-compose
    ngrok
    
    # Cloud tools
    kubectl
    
    # Spell checkers
    ispell
    hunspell
    hunspellDicts.en_US
  ];
}