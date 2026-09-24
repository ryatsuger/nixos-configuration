{ config, lib, pkgs, osConfig, ... }:

{
  home.packages = [
    pkgs.claude-code
    pkgs.gemini-cli
    # Pinned to the upstream v2 release by overlays/opencode.nix — nixpkgs is a
    # whole major line behind (26.05 carries 1.15.10) and builds it from source
    # via bun.
    pkgs.opencode
  ] ++ lib.optionals
    ((osConfig.mySystem.enableDesktop or false)
      && !(osConfig.mySystem.headless or false)) [
    # GUI app (bundles Electron). Only on real desktop machines — excluded
    # from headless cloud VMs (azure/gce) so they don't compile Electron
    # from source even when the desktop profile is enabled for VNC.
    pkgs.obsidian
  ];
}
