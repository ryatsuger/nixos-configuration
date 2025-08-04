{
  programs.alacritty = {
    enable = true;
    settings = {
      # Font configuration
      font = {
        # Normal (roman) font face
        normal = {
          family = "MesloLGS Nerd Font";
          style = "Regular";
        };

        # Bold font face
        bold = {
          family = "MesloLGS Nerd Font";

          # The `style` can be specified to pick a specific face.
          style = "Bold";
        };

        # Italic font face
        italic = {
          family = "MesloLGS Nerd Font";
          style = "Italic";
        };

        # Point size
        size = 12.0;  # Reduced from 16.0 for better scaling

        offset = {
          y = 3; # increase line height
        };
      };

    };
  };
}
