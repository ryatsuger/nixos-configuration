{ config, lib, pkgs, ... }:

{
  home.packages = [
    pkgs.claude-code
    pkgs.obsidian
    pkgs.gemini-cli
  ];
}
