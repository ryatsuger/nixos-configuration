{ config, lib, ... }:

{
  programs.openclaw = {
    enable = true;
    
    # Path to managed documents directory
    documents = ../../../documents/openclaw;

    # OpenClaw configuration
    config = {
      gateway = {
        mode = "local";
        auth = {
          token = "XihJeWwkMv2AmeuyfFQxH766jYTjtbKB";
        };
      };

      channels.telegram = {
        tokenFile = "/home/ruiyang/.secrets/telegram-bot-token";
        allowFrom = [ 6731851735 ];
        groups = {
          "*" = {
            requireMention = true;
          };
        };
      };
    };

    # Systemd service configuration
    systemd = {
      enable = true;
      # Environment file for API keys (not stored in nix store)
      environmentFile = "/home/ruiyang/.secrets/openclaw-env";
    };

    instances.default = {
      enable = true;
      plugins = [];
    };
  };
}
