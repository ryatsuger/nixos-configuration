# Headless TigerVNC server, secured by binding to localhost only.
#
# The RFB port is NEVER exposed to the network: Xvnc is started with
# `-localhost`, so it listens on 127.0.0.1 only. You reach it through an
# SSH tunnel, which means the transport is encrypted and authenticated by
# your existing SSH keys. The VNC password is a second factor, not the
# primary gate.
#
#   Connect from your laptop:
#     ssh -N -L 5901:localhost:5901 ruiyang@<host>
#     vncviewer localhost:5901      # in another terminal
#
# One-time secret setup on the host (out-of-store, like the cloudflared
# token on the vmware host):
#     umask 077
#     sudo mkdir -p /etc/vnc
#     vncpasswd -f <<<'your-vnc-password' | sudo tee /etc/vnc/passwd >/dev/null
#     sudo chown ruiyang /etc/vnc/passwd
#
{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.vnc;
  port = 5900 + cfg.display;

  # Reuse the same patched dwm the X11 desktop module builds, so the VNC
  # session matches the local hosts.
  dwmPackage =
    (pkgs.dwm.overrideAttrs { }).override { patches = [ ../desktop/dwm.patch ]; };

  # Everything the launcher and session need on PATH. tigervnc provides
  # Xvnc; the service runs with a minimal PATH (no ambient system path), so
  # this must be self-contained. dwm spawns st (Mod+Shift+Enter) and dmenu
  # (Mod+p).
  sessionPackages = with pkgs; [
    tigervnc
    dwmPackage
    st
    dmenu
    xsetroot
    xdpyinfo
    coreutils
    dbus # dbus-run-session execs `dbus-daemon` by bare name from PATH
  ] ++ cfg.extraPackages;

  vncSession = pkgs.writeShellScript "vnc-session" ''
    set -u
    # sessionPackages first (the launcher essentials), then the system and
    # per-user profiles so every installed desktop app (browsers, file
    # manager, etc.) is launchable from dwm/dmenu without listing each here.
    export PATH=${lib.makeBinPath sessionPackages}:/run/current-system/sw/bin:/etc/profiles/per-user/${cfg.user}/bin:$PATH
    DISPLAY_NUM=":${toString cfg.display}"

    # Clean up a stale lock/socket left by a previous crash, otherwise Xvnc
    # refuses to claim the display.
    rm -f "/tmp/.X${toString cfg.display}-lock" \
          "/tmp/.X11-unix/X${toString cfg.display}" 2>/dev/null || true

    Xvnc "$DISPLAY_NUM" \
      -rfbport ${toString port} \
      -localhost \
      -geometry ${cfg.geometry} \
      -depth 24 \
      ${lib.optionalString cfg.lockResolution "-AcceptSetDesktopSize=0"} \
      -SecurityTypes VncAuth \
      -PasswordFile ${cfg.passwordFile} \
      -desktop ${config.networking.hostName} &
    xvnc_pid=$!
    trap 'kill "$xvnc_pid" 2>/dev/null || true' EXIT TERM INT

    export DISPLAY="$DISPLAY_NUM"
    # Wait for the X display to accept connections before starting the WM.
    for _ in $(seq 1 100); do
      xdpyinfo >/dev/null 2>&1 && break
      sleep 0.1
    done

    xsetroot -solid '#222222'

    # Run dwm under a dbus session so GUI apps (browsers, 1Password) work.
    # Not exec'd: when dwm exits we fall through to the trap and tear Xvnc
    # down cleanly so systemd can restart the whole session.
    ${pkgs.dbus}/bin/dbus-run-session -- dwm
  '';
in
{
  options.mySystem.vnc = {
    enable = lib.mkEnableOption
      "headless TigerVNC server (localhost-only, dwm session, reached over SSH)";

    user = lib.mkOption {
      type = lib.types.str;
      default = config.mySystem.username;
      description = "User the VNC session runs as.";
    };

    display = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "X display number. The RFB port is 5900 + this value.";
    };

    geometry = lib.mkOption {
      type = lib.types.str;
      default = "1920x1080";
      description = "Virtual screen geometry.";
    };

    lockResolution = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Pin the framebuffer to `geometry` and refuse client-driven resize
        (Xvnc `-AcceptSetDesktopSize=0`). Without this, a viewer connecting
        with a small window shrinks the remote desktop (often to an unusably
        tiny size). Set false if you want the desktop to track the client.
      '';
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/vnc/passwd";
      description = ''
        Path to a TigerVNC password file created with `vncpasswd -f`.
        Kept out of the Nix store (it is a secret). See the header of this
        module for the one-time setup command.
      '';
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages to put on the VNC session PATH.";
    };
  };

  config = lib.mkIf cfg.enable {
    # vncviewer / vncpasswd available on the host for management.
    environment.systemPackages = [ pkgs.tigervnc ];

    systemd.services.vncserver = {
      description =
        "TigerVNC server (localhost-only) on display :${toString cfg.display}";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        # NB: do NOT set PAMName = "login" here. pam_systemd would register a
        # login session and migrate Xvnc/dwm into a per-user session scope,
        # escaping this service's cgroup — they'd then survive restarts as
        # orphans holding display :N. Keeping the session in the service
        # cgroup lets systemd stop/restart it cleanly.
        ExecStart = vncSession;
        # KillMode control-group (default) tears down Xvnc + dwm + dbus
        # together when the unit stops.
        Restart = "on-failure";
        RestartSec = 5;
        # Give the WM/Xvnc time to shut down on stop.
        TimeoutStopSec = 10;
      };
    };
  };
}
