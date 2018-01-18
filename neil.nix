{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.useSandbox = true;

  nixpkgs.config = {
    allowUnfree = true;
    vim.ftNixSupport = true;

    packageOverrides = pkgs: {
      spotify = pkgs.spotify.overrideDerivation (oldAttrs: {
        src = pkgs.fetchurl {
          url = "http://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.0.69.336.g7edcc575-39_amd64.deb";
          sha256 = "ed0dc69f7e50879fcf7bd1bb67e33f08af0c17ebd7bb608ce4e7a143dec1022e";
        };
      });
    };
  };

  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems = {
    "/boot" = {
      device = "systemd-1";
      fsType = "autofs";
    };

    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/53ef1c9e-39a3-41fe-996b-98ad91afa021";
      fsType = "btrfs";
      options = [ "subvol=@docker" ];
    };
  };

  networking = {
    hostName = "buzz";
    firewall.allowedTCPPorts = [ 12345 ];
    #firewall.allowedUDPPorts = [ 67 68 ];
    #wireless.enable = true;
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
  #time.timeZone = "Europe/Berlin";

  security.sudo.wheelNeedsPassword = false;

  environment = {
    etc."binfmt.d/qemu-aarch64.conf".text = ":qemu-aarch64:M::\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\xb7:\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xff\\xff:/usr/bin/qemu-aarch64:\n";

    shells = [ "${pkgs.zsh}/bin/zsh" ];

    sessionVariables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      (import ./vim.nix)

      sqlite
      autoconf
      automake
      gettext
      gpgme
      cmake

      bind
      chromium
      docker
      file
      firefox-beta-bin
      gcc
      gcc-arm-embedded
      git
      gnumake
      gnupg
      iftop
      iotop
      #kicad
      mutt
      patchelf
      #qt55.full
      rkt
      spotify
      tigervnc
      tmux
      usbutils
      vim
      vimPlugins.vundle
      w3m
      wings
      wget
      xorg.xmodmap
    ];
  };

  programs.zsh.enable = true;

  services = {
    xserver = {
      enable     = true;
      layout     = "us";
      xkbVariant = "dvp";
      xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";

      desktopManager.gnome3.enable = true;
      desktopManager.xterm.enable = false;

      displayManager.gdm.enable = true;

      synaptics.enable = false;
    };

    udev.extraRules = ''
      ATTRS{idVendor}=="2544", ATTRS{idProduct}=="0002", MODE="666"
      ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1015", GROUP="wheel", MODE="666", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
      SUBSYSTEM=="usb", ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
    '';

    avahi = {
      enable   = true;
      nssmdns  = true;
    };

    printing.enable = true;
    tcsd.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };

    virtualbox.host.enable = true;
  };

  users.extraUsers.alex = {
    name        = "alex";
    group       = "users";
    extraGroups = [ "wheel" "plugdev" "rkt" ];
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
