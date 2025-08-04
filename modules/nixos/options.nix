{ lib, ... }:

{
  options = {
    mySystem = {
      enableDesktop = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable desktop environment and GUI applications";
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
    };
  };
}