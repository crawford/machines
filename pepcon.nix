{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix = {
    autoOptimiseStore = true;
    buildCores        = 8;
    useSandbox        = true;
    gc.automatic = true;
  };

  nixpkgs.config = {
    allowUnfree                    = true;
    vim.ftNixSupport               = true;
    virtualbox.enableExtensionPack = true;
  };

  boot.loader = {
    systemd-boot.enable      = true;
    efi.canTouchEfiVariables = true;
    timeout                  = 1;
  };

  networking.hostName = "pepcon";

  i18n = {
    consoleFont   = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "US/Pacific";

  security.sudo.wheelNeedsPassword = false;

  environment = {
    shells = [ "${pkgs.zsh}/bin/zsh" ];

    sessionVariables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      (import ./vim-config.nix)
      tmux
      zsh
    ];
  };

  programs = {
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      historyLimit = 50000;
      terminal = "screen-256color";
      extraTmuxConf = ''
        set-option -g status-bg black
        set-option -g status-fg white
        set-window-option -g window-status-current-bg black
        set-window-option -g window-status-current-fg cyan
      '';
    };

    zsh = {
      enable = true;
      interactiveShellInit = ''
        cat << EOF > $HOME/.zshrc
        source ${import ./zsh-config.nix}
        EOF
      '';
    };
  };

  services = {
    xserver = {
      enable     = true;
      layout     = "us";
      xkbVariant = "dvp";
      xkbOptions = "ctrl:nocaps";

      desktopManager.xterm.enable = false;

      displayManager.slim = {
        enable      = true;
        defaultUser = "alex";
        autoLogin   = true;
      };

      windowManager = {
        awesome.enable = true;
        default        = "awesome";
      };
    };

    udev.extraRules = ''
      ATTR{idVendor}=="1366", ATTR{idProduct}=="1010", MODE="0666"
      ATTR{idVendor}=="1366", ATTR{idProduct}=="1015", MODE="0666"
      KERNEL=="hidraw*", ATTRS{idVendor}=="c251", ATTRS{idProduct}=="f001", MODE="0666"
    '';

    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };

    sshguard.enable = true;
  };

  users.extraUsers.alex = {
    isNormalUser = true;
    extraGroups  = [ "wheel" ];
    shell        = "${pkgs.zsh}/bin/zsh";
  };
}
