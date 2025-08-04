{ config, lib, pkgs, ... }:

{
  options.mySystem.desktop = {
    enableChineseInput = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Chinese input method support (fcitx5)";
    };
  };

  config = lib.mkIf (config.mySystem.enableDesktop && config.mySystem.desktop.enableChineseInput) {
    # Chinese input method
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        fcitx5-chinese-addons
        fcitx5-gtk
        libsForQt5.fcitx5-qt
      ];
    };
  };
}