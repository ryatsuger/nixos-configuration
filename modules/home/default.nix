{ osConfig, lib, ... }:

{
  imports = [
    # Base configuration for all users
    ./base.nix
    
    # Shell environment
    ./shell/git.nix
    ./shell/zsh.nix
    ./shell/direnv.nix
    ./shell/ssh.nix
    
    # Editors
    ./editors/emacs.nix
    
    # Work tools
    ./work/ai.nix
    ./work/aws.nix
  ] ++ lib.optionals (osConfig.mySystem.enableDesktop or false) [
    # Desktop-only modules
    ./terminal/kitty.nix
    ./desktop/screen-lock.nix
    ./desktop/browsers.nix
    # ./editors/vscode.nix  # Uncomment if needed
  ];
}