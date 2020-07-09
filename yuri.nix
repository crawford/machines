{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./redhat-config.nix
    ./rust.nix
  ];

  boot = {
    binfmt.registrations."qemu-aarch64" = {
      interpreter = "${pkgs.qemu}/bin/qemu-aarch64";
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00'';
      mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
    };

    loader = {
      grub.enable              = false;
      systemd-boot.enable      = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "yuri";

    firewall = {
      allowedTCPPorts   = [ 5201 16509 ];
      trustedInterfaces = [ "vnet0" "vnet1" ];
    };

    networkmanager = {
      dns    = "dnsmasq";
      enable = true;
    };
  };

  hardware = {
    enableAllFirmware = true;

    bluetooth = {
      enable      = true;
      powerOnBoot = false;
    };

    pulseaudio = {
      enable  = true;
      package = pkgs.pulseaudioFull;
    };
  };

  programs = {
    gnupg.agent.enable = true;
    zsh.promptColor    = "cyan";
  };

  services = {
    btrfs.autoScrub.enable = true;
    fwupd.enable           = true;

    xserver = {
      layout       = "us";
      videoDrivers = [ "nvidia" ];
      xkbOptions   = "terminate:ctrl_alt_bksp, ctrl:nocaps";
      xkbVariant   = "dvp";

      desktopManager.gnome3.enable = true;
      desktopManager.xterm.enable  = false;

      displayManager.gdm = {
        autoSuspend = false;
        enable      = true;
        wayland     = false;
      };
    };

    openssh = {
      enable                 = true;
      passwordAuthentication = false;
      permitRootLogin        = "no";
    };

    avahi = {
      enable   = true;
      nssmdns  = true;
    };

    printing = {
      enable  = true;
      drivers = [ pkgs.gutenprint pkgs.hplip ];
    };

    tcsd.enable = true;
  };

  virtualisation = {
    docker = {
      autoPrune.enable = true;
      enable           = true;
      storageDriver    = "btrfs";
    };

    libvirtd = {
      enable       = true;
      extraOptions = [ "--listen" ];
      onShutdown   = "shutdown";

      extraConfig = ''
        listen_tls = 0
        listen_tcp = 1
        auth_tcp = "none"
      '';
    };
  };

  users.extraUsers = {
    aaron.shell      = "${pkgs.bashInteractive}/bin/bash";
    adahiya          = {};
    alex.extraGroups = [ "wheel" "plugdev" "libvirtd" ];
  };

  system = {
    stateVersion = "20.03";

    activationScripts.lib64 = ''
      echo "setting up /lib64..."
      mkdir -p /lib64
      ln -sfT ${pkgs.stdenv.glibc}/lib/ld-linux-x86-64.so.2 /lib64/.ld-linux-x86-64.so.2
      mv -Tf /lib64/.ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
    '';
  };
}
