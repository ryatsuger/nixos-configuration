{ config, lib, pkgs, ... }:

{
  # Google Workspace CLI, plus the gcloud SDK it shells out to.
  #
  # `gws auth setup` drives gcloud to create/select the GCP project, enable the
  # Workspace APIs and mint the desktop OAuth client, so gcloud is a real
  # runtime dependency of the setup path rather than an unrelated tool.
  home.packages = with pkgs; [
    gws
    google-cloud-sdk
  ];

  # gws keeps OAuth credentials in a Secret Service keyring by default. None of
  # these hosts run one — the cloud hosts are headless, and the desktop profile
  # uses ly + hyprland/x11 without gnome-keyring — so the default backend has
  # nothing to talk to and login fails. The file backend stores the credentials
  # encrypted under ~/.config/gws instead.
  home.sessionVariables.GOOGLE_WORKSPACE_CLI_KEYRING_BACKEND = "file";
}
