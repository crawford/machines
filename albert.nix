{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./redhat-config.nix
  ];

  nix = {
    autoOptimiseStore = true;
    buildCores = 8;
    useSandbox = true;
    gc.automatic = true;
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    cleanTmpDir = true;
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    networkmanager.enable = true;
    hostName = "albert";
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  i18n = {
    consoleFont   = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "US/Pacific";
  #time.timeZone = "America/New_York";

  security.sudo.wheelNeedsPassword = false;

  environment = {
    shells = [ "${pkgs.zsh}/bin/zsh" ];

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  programs = {
    tmux = {
      enable = true;
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
      xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";

      desktopManager = {
        gnome3.enable = true;
        xterm.enable = false;
      };

      displayManager.gdm.enable = true;
    };

    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplip ];
    };

    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
      SUBSYSTEM=="usb", ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
    '';
  };

  users.extraUsers.alex = {
    name        = "alex";
    group       = "users";
    extraGroups = [ "wheel" "plugdev" ];
    createHome  = true;
    home        = "/home/alex";
    shell       = "${pkgs.zsh}/bin/zsh";
  };
}
