{ config, lib, pkgs, osConfig, ... }:

{
  config = lib.mkIf (osConfig.mySystem.enableDesktop or false) {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;

      settings = {
        # Monitor configuration for Parallels VM
        monitor = "Virtual-1,2560x1600@60,0x0,1.6";

        # Input configuration
        input = {
          kb_layout = "us";
          kb_options = "caps:ctrl_modifier";
          follow_mouse = 1;
          touchpad.natural_scroll = true;
        };

        # General settings
        general = {
          gaps_in = 2;
          gaps_out = 4;
          border_size = 1;
          layout = "dwindle";
        };

        # Decoration (disabled for VM performance)
        decoration = {
          rounding = 5;
          blur.enabled = false;
          shadow.enabled = false;
        };

        # Animations (disabled for VM)
        animations.enabled = false;

        # Cursor settings
        cursor = {
          no_hardware_cursors = true;
        };

        # Keybindings (matching DWM setup)
        "$mod" = "SUPER";
        bind = [
          # Launch applications
          "$mod, Return, exec, kitty"
          "$mod, Q, exec, kitty"
          "$mod, E, exec, emacs"
          "$mod, R, exec, fuzzel"
          "$mod, S, exec, grim -g \"$(slurp)\" - | swappy -f -"

          # Window management
          "$mod, C, killactive"
          "$mod, M, exit"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
          "$mod, Tab, workspace, previous"

          # Focus navigation (DWM j/k style)
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"

          # Resize windows (DWM h/l style)
          "$mod SHIFT, H, resizeactive, -50 0"
          "$mod SHIFT, L, resizeactive, 50 0"
          "$mod SHIFT, J, resizeactive, 0 50"
          "$mod SHIFT, K, resizeactive, 0 -50"

          # Swap windows
          "$mod CTRL, J, swapwindow, d"
          "$mod CTRL, K, swapwindow, u"
          "$mod CTRL, H, swapwindow, l"
          "$mod CTRL, L, swapwindow, r"

          # Workspaces 1-9
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"

          # Move window to workspace
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
        ];

        # Mouse bindings
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
