{ lib, ... }:

{
  options = {
    mySystem = {
      enableDesktop = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable desktop environment and GUI applications";
      };

      headless = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Headless host (no local display). Disables local SSH agent in favor of agent forwarding.";
      };
      
      username = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
        description = "Primary username for the system";
        example = "alice";
      };
      
      userFullName = lib.mkOption {
        type = lib.types.str;
        default = "NixOS User";
        description = "Full name of the primary user";
        example = "Alice Smith";
      };
      
      userEmail = lib.mkOption {
        type = lib.types.str;
        default = "user@example.com";
        description = "Email address of the primary user";
        example = "alice@example.com";
      };

      # Deliberately SEPARATE from userEmail/userFullName. Those name the system
      # account; these are the git author stamped into every commit on this box.
      # Tying them together put a work address on personal commits, where GitHub
      # attributed them to the wrong account entirely, and undoing that needed a
      # history rewrite. A work repo sets its own identity per-clone instead.
      gitUserName = lib.mkOption {
        type = lib.types.str;
        default = "NixOS User";
        description = "git user.name, the author recorded in commits";
        example = "alice";
      };

      gitUserEmail = lib.mkOption {
        type = lib.types.str;
        default = "user@example.com";
        description = "git user.email, the author recorded in commits";
        example = "alice@personal.example";
      };
    };
  };
}