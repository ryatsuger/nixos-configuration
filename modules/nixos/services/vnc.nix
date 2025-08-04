{ config, pkgs, lib, ... }:

let
  cfg = config.services.vncServer;
in
{
  options.services.vncServer = {
    enable = lib.mkEnableOption "VNC server";
    
    user = lib.mkOption {
      type = lib.types.str;
      default = config.mySystem.username;
      description = "User account under which VNC server runs";
    };
    
    display = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "Display number for VNC server";
    };
    
    port = lib.mkOption {
      type = lib.types.int;
      default = 5901;
      description = "Port for VNC server";
    };
    
    geometry = lib.mkOption {
      type = lib.types.str;
      default = "1920x1080";
      description = "Screen geometry for VNC session";
    };
    
    depth = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Color depth for VNC session";
    };
    
    compression = lib.mkOption {
      type = lib.types.int;
      default = 6;
      description = "Compression level (0-9, higher = more compression)";
    };
    
    quality = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "JPEG quality (0-9, lower = faster but worse quality)";
    };
    
    localhostOnly = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Only allow connections from localhost (more secure)";
    };
    
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for VNC";
    };
    
    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to VNC password file";
    };
    
    windowManager = lib.mkOption {
      type = lib.types.str;
      default = let
        patchedDwm = pkgs.dwm.override {
          patches = [ ../desktop/dwm.patch ];
        };
      in "${patchedDwm}/bin/dwm";
      description = "Window manager to run in VNC session";
    };
  };

  config = lib.mkIf cfg.enable (let
    userCfg = config.users.users.${cfg.user};
    homeDir = userCfg.home or "/home/${cfg.user}";
    vncDir = "${homeDir}/.vnc";
    userGroup = userCfg.group or "users";
    localhostFlag = if cfg.localhostOnly then "-localhost" else "-localhost no";
    actualPort = 5900 + cfg.display;
  in {
    # Install TigerVNC
    environment.systemPackages = with pkgs; [
      tigervnc
    ];

    # Create systemd service for VNC
    systemd.services.vncserver = {
      description = "VNC Server for ${cfg.user}";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      preStart = ''
        # Create xstartup file if it doesn't exist
        if [ ! -f ${vncDir}/xstartup ]; then
          cat > ${vncDir}/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Start window manager with restart on crash
while true; do
  ${cfg.windowManager}
  if [ $? -eq 0 ]; then
    echo "Window manager exited normally" >&2
    break
  fi
  echo "Window manager crashed with exit code $?, restarting in 2 seconds..." >&2
  sleep 2
done
EOF
          chmod +x ${vncDir}/xstartup
        fi
      '';
      
      # Use ExecStartPre with root privileges for password setup
      path = with pkgs; [ 
        coreutils 
        tigervnc 
        xorg.xinit
        xorg.xauth
        xorg.xorgserver
        xorg.xset
        procps
      ];
      
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        # Inherit system PATH
        Environment = "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin";
        # Start Xvnc in foreground
        ExecStart = "${pkgs.tigervnc}/bin/Xvnc :${toString cfg.display} -geometry ${cfg.geometry} -depth ${toString cfg.depth} -rfbauth ${vncDir}/passwd -desktop \"VNC Desktop\" -AlwaysShared ${localhostFlag} -CompareFB 2 -ZlibLevel ${toString cfg.compression} -ImprovedHextile 1";
        # Start window manager after Xvnc is running
        ExecStartPost = "${pkgs.bash}/bin/bash -c 'for i in {1..30}; do ${pkgs.xorg.xset}/bin/xset -display :${toString cfg.display} q >/dev/null 2>&1 && break || sleep 0.5; done && DISPLAY=:${toString cfg.display} ${cfg.windowManager} &'";
        ExecStop = "pkill -f \"Xvnc :${toString cfg.display}\"";
        Restart = "on-failure";
        RestartSec = "10s";
      } // lib.optionalAttrs (cfg.passwordFile != null) {
        ExecStartPre = "+${pkgs.writeShellScript "setup-vnc-password" ''
          if [ -f "${cfg.passwordFile}" ]; then
            mkdir -p ${vncDir}
            ${pkgs.tigervnc}/bin/vncpasswd -f < "${cfg.passwordFile}" > ${vncDir}/passwd
            chmod 600 ${vncDir}/passwd
            chown ${cfg.user}:${userGroup} ${vncDir}/passwd
          else
            echo "Warning: Password file ${cfg.passwordFile} not found"
            exit 1
          fi
        ''}";
      };
    };

    # Open firewall if requested
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ actualPort ];

    # Use systemd tmpfiles to create VNC directory with proper permissions
    systemd.tmpfiles.rules = [
      "d ${vncDir} 0700 ${cfg.user} ${userGroup} -"
    ];
    
    # Validate configuration
    assertions = [
      {
        assertion = cfg.passwordFile != null -> cfg.passwordFile != "";
        message = "VNC password file path cannot be empty when specified";
      }
      {
        assertion = cfg.port >= 5900 && cfg.port <= 5999;
        message = "VNC port must be between 5900 and 5999";
      }
      {
        assertion = cfg.port == 5900 + cfg.display;
        message = "VNC port must be 5900 + display number (expected ${toString (5900 + cfg.display)} for display ${toString cfg.display})";
      }
      {
        assertion = cfg.display >= 0 && cfg.display <= 99;
        message = "VNC display number must be between 0 and 99";
      }
    ];
  });
}