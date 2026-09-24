{ ... }: {
  programs.tmux = {
    enable = true;
    mouse = true;
    # Use a 256-color-capable terminfo inside tmux instead of the default "screen".
    terminal = "tmux-256color";
    extraConfig = ''
      # Pass truecolor (24-bit) through from the outer terminal (Ghostty/xterm-ghostty, alacritty, kitty).
      set -ga terminal-overrides ",xterm-ghostty:RGB,xterm-256color:RGB,alacritty:RGB,*:RGB"
    '';
  };
}
