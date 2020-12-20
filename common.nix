{ config, pkgs, ... }:

{
  imports = [
    ./vim.nix
    ./zsh.nix
  ];

  console.keyMap = "dvp";

  nix = {
    allowedUsers      = [ "alex" ];
    autoOptimiseStore = true;

    gc = {
      automatic = true;
      options   = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot.cleanTmpDir = true;

  environment = {
    homeBinInPath = true;

    shellAliases = {
      ush = "ssh -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null";
      ucp = "scp -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null";
      utc = "TZ=UTC date";
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  programs = {
    command-not-found.enable = true;
    iftop.enable             = true;
    iotop.enable             = true;
    mtr.enable               = true;
    vim.defaultEditor        = true;

    tmux = {
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
  };

  security.sudo.wheelNeedsPassword = false;

  services = {
    sshguard.enable = true;

    openssh = {
      enable                 = true;
      passwordAuthentication = false;
      permitRootLogin        = "no";
    };

    xserver = {
      layout     = "us";
      xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";
      xkbVariant = "dvp";
    };
  };

  time.timeZone = pkgs.lib.mkOverride 1100 "US/Pacific";

  users = {
    defaultUserShell = "${pkgs.zsh}/bin/zsh";

    users.alex = {
      isNormalUser = true;
      extraGroups  = [ "wheel" ];
    };
  };
}
