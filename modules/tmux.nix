{
  programs.tmux = {
    enable       = true;
    historyLimit = 50000;
    keyMode      = "vi";
    terminal     = "screen-256color";

    extraConfig = ''
      set-option -g status-bg black
      set-option -g status-fg white
      set-window-option -g window-status-current-style bg=black
      set-window-option -g window-status-current-style fg=cyan
    '';
  };
}
