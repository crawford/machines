# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./redhat-config.nix
  ];

  nix = {
    autoOptimiseStore = true;
    buildCores = 32;
    useSandbox = true;
    gc.automatic = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    vim.ftNixSupport = true;
    #virtualbox.enableExtensionPack = true;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems = {
    "/var/lib/docker" = {
      device = "/dev/disk/by-label/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@docker" ];
    };
  };

  networking = {
    networkmanager.enable = true;
    hostName = "yuri";
    firewall.allowedTCPPorts = [ 12345 ];
    #firewall.allowedUDPPorts = [ 67 68 ];
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };

    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
  };

  i18n = {
    consoleFont   = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "US/Pacific";
  #time.timeZone = "America/New_York";
  #time.timeZone = "Europe/Berlin";

  security.sudo.wheelNeedsPassword = false;

  environment = {
    #etc."binfmt.d/qemu-aarch64.conf".text = ":qemu-aarch64:M::\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\xb7:\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xff\\xff:/usr/bin/qemu-aarch64:\n";

    shells = [ "${pkgs.zsh}/bin/zsh" ];

    sessionVariables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      (import ./vim-config.nix)

      gnupg
      vim
      vimPlugins.vundle
      xorg.xmodmap
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
      xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";

      desktopManager.gnome3.enable = true;
      desktopManager.xterm.enable = false;

      displayManager.gdm.enable = true;
      videoDrivers = [ "nvidia" ];
    };

    udev.extraRules = ''
      ATTRS{idVendor}=="2544", ATTRS{idProduct}=="0002", MODE="666"
      ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1015", GROUP="wheel", MODE="666", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
      SUBSYSTEM=="usb", ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
    '';

    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };

    sshguard.enable = true;

    avahi = {
      enable   = true;
      nssmdns  = true;
    };

    printing.enable = true;

    tcsd.enable = true;
  };

  #system.autoUpgrade.enable = true;

  virtualisation = {
    docker = {
      autoPrune.enable = true;
      enable = true;
      storageDriver = "btrfs";
    };

    rkt = {
      enable = true;
      gc.automatic = true;
    };

    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
    };

    #virtualbox.host.enable = true;
  };

  users.extraUsers.alex = {
    name        = "alex";
    group       = "users";
    extraGroups = [ "wheel" "plugdev" "rkt" "libvirtd" ];
    createHome  = true;
    home        = "/home/alex";
    shell       = "/run/current-system/sw/bin/zsh";
  };

  users.extraUsers.rkt = {
    name        = "rkt";
    group       = "rkt";
    createHome  = false;
  };
}
