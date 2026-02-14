{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.mySystem.enableDesktop {
    fonts = {
      packages = with pkgs; [
        # Programming fonts
        jetbrains-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.meslo-lg
        nerd-fonts.symbols-only
        
        # System fonts
        dejavu_fonts
        liberation_ttf
        noto-fonts
        noto-fonts-color-emoji
        
        # CJK fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        source-han-sans
        source-han-serif
        source-han-mono
        
        # Chinese specific
        wqy_zenhei
        wqy_microhei
        
        # Japanese specific
        ipafont
        ipaexfont
        
        # Korean specific
        nanum
        
        # Programming font with CJK
        sarasa-gothic
      ];
      
      # Font configuration
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" "Noto Serif CJK SC" ];
          sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
          monospace = [ "JetBrains Mono" "Sarasa Mono SC" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}