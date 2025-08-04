{ pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    history = {
      size = 100000;
      save = 100000;  # Reduced from 2 million for better performance
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "npm" "history" "node" "direnv" "1password" "aws" ];
    };

    plugins = [
      {
        name = "powerlevel10k-config";
        src = ./p10k;
        file = "p10k.zsh";
      }
      {
        name = "zsh-powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
        file = "powerlevel10k.zsh-theme";
      }
      {
        name = "nix-shell";
        file = "nix-shell.plugin.zsh";
        src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
      }
    ];

    shellAliases = {
      update = "sudo -E nixos-rebuild switch --flake ~/.config/nixos#$(hostname)";
    };

    # Add this section for TRAMP compatibility
    initContent = lib.mkOrder 550 ''
      # Speed up TRAMP by providing a simple environment when TERM=dumb
      if [[ "$TERM" == "dumb" ]]; then
        # Attempt to load direnv hook first if it's essential for TRAMP
        # and emacs-direnv package is not used/sufficient.
        # This assumes 'direnv' is in PATH.
        # Be cautious: direnv hooks can sometimes be too "chatty" for TRAMP.
        if command -v direnv &>/dev/null; then
          eval "$(direnv hook zsh)"
        fi

        # Unset features that can interfere with TRAMP's prompt detection
        unsetopt zle # Disable Zsh Line Editor
        unsetopt prompt_cr # Don't add a carriage return before the prompt
        unsetopt prompt_sp # Don't add a space after the prompt if it's at the end of a line with no CR

        # If Oh My Zsh or P10k functions are already defined and causing issues,
        # you might need to undefine them explicitly here for TERM=dumb.
        # e.g., unfunction p10k-prompt-finalize prompt_powerlevel10k_setup
        # This is usually not needed if the `return` below is effective.

        # Ensure a very simple prompt for TRAMP
        PS1='$ '
        # Skip any further Oh My Zsh / Powerlevel10k / plugin initialization
        return
      fi
    '';

    sessionVariables = {
      LANG = "en_US.UTF-8";
      EDITOR = "emacs";
    };
  };
}
