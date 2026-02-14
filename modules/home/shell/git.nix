{ pkgs, lib, osConfig, ... }:

{
  programs.home-manager.enable = true;
  
  home.packages = [ pkgs.gh ];
  
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = osConfig.mySystem.userFullName or "NixOS User";
        email = osConfig.mySystem.userEmail or "user@example.com";
      };
      pull = { rebase = false; };
      push = { autoSetupRemote = true; };
      core = { ignorecase = false; };
      # 1Password SSH signing support
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
      # Uncomment these lines if you want to enable commit signing:
      # commit = {
      #   gpgsign = true;
      # };
      # user = {
      #   signingKey = "your-ssh-public-key-here";
      # };
    };
  };
}
