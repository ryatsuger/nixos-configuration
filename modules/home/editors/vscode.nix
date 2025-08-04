{pkgs, ...}:

{
  programs.vscode = {
    enable = true;
    # extensions = with pkgs.vscode-marketplace; [
    #   jnoortheen.nix-ide
    #   dracula-theme.theme-dracula
    # ];
  };
}
