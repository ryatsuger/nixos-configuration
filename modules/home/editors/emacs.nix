{pkgs, ...}:
let
  # Emacs with vterm for both X11 and Wayland
  emacs-x11 = pkgs.emacs.pkgs.withPackages (epkgs: [ epkgs.vterm ]);
  emacs-wayland = pkgs.emacs-pgtk.pkgs.withPackages (epkgs: [ epkgs.vterm ]);

  # Wrapper that detects session type and launches appropriate emacs
  emacs-wrapper = pkgs.symlinkJoin {
    name = "emacs-auto";
    paths = [
      (pkgs.writeShellScriptBin "emacs" ''
        if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
          exec ${emacs-wayland}/bin/emacs "$@"
        else
          exec ${emacs-x11}/bin/emacs "$@"
        fi
      '')
      (pkgs.writeShellScriptBin "emacsclient" ''
        if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
          exec ${emacs-wayland}/bin/emacsclient "$@"
        else
          exec ${emacs-x11}/bin/emacsclient "$@"
        fi
      '')
    ];
  };
in
{
  home.packages = [ emacs-wrapper ];
}
