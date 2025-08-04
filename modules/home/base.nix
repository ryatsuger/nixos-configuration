{ pkgs, ... }:

{
  # Font configuration for user
  fonts.fontconfig.enable = true;
  
  # Basic packages every user should have
  home.packages = with pkgs; [
    # User-specific fonts (only ones not in system fonts)
    powerline-fonts
  ];
  
  # Enable home-manager
  programs.home-manager.enable = true;
}