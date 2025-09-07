{ pkgs, ... }:

{
  programs.google-chrome = {
    enable = false;
  };
  
  # Additional browser-related packages
  home.packages = with pkgs; [
    # Browser extensions and tools can go here
  ];
}