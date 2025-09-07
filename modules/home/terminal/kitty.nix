{
  programs.kitty = {
    enable = true;
    settings = {
      # Font configuration
      font_family = "MesloLGS Nerd Font";
      bold_font = "MesloLGS Nerd Font Bold";
      italic_font = "MesloLGS Nerd Font Italic";
      bold_italic_font = "MesloLGS Nerd Font Bold Italic";
      font_size = 12;
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
      
      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      
      # Window
      window_padding_width = 5;
      hide_window_decorations = false;
      
      # Terminal bell
      enable_audio_bell = false;
      visual_bell_duration = 0;
      
      # Color scheme (optional - you can customize these)
      background_opacity = "0.95";
      
      # Scrollback
      scrollback_lines = 10000;
      
      # URL handling
      open_url_with = "default";
      detect_urls = true;
      
      # Tab bar
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
    };
    
    # Key mappings (optional)
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "cmd+n" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "cmd+right" = "next_tab";
      "cmd+left" = "previous_tab";
    };
  };
}