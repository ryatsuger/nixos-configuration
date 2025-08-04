{ config, lib, pkgs, ... }:

{
  # Debug: Print all configured users during activation
  system.activationScripts.debugUsers = {
    text = ''
      echo ""
      echo "=== NixOS User Configuration Debug ==="
      echo "Primary username: ${config.mySystem.username}"
      echo "User full name: ${config.mySystem.userFullName}"
      echo "User email: ${config.mySystem.userEmail}"
      echo ""
      echo "Normal users that will be ensured to exist:"
      ${lib.concatMapStringsSep "\n" (user: 
        lib.optionalString (config.users.users.${user}.isNormalUser or false) ''
          echo "  - ${user} (uid: ${toString config.users.users.${user}.uid}, groups: ${toString config.users.users.${user}.extraGroups or []})"
        ''
      ) (builtins.attrNames config.users.users)}
      echo ""
      echo "Mutable users is: ${if config.users.mutableUsers then "true (existing users won't be deleted)" else "false (only declared users will exist)"}"
      echo "=== End User Debug ==="
      echo ""
    '';
  };
  
  # Warning during nixos-rebuild
  warnings = [
    "User configuration debug: Primary user will be '${config.mySystem.username}' with email '${config.mySystem.userEmail}'"
  ];
}