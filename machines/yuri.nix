{ config, pkgs, ... }:

{
  imports = [
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc>
    <nixos-hardware/common/pc/ssd>
    ./.
    ../modules/gnome.nix
    ../modules/redhat.nix
    ../modules/rust.nix
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

  environment.etc = {
    subuid.text = "alex:100000:65536";
    subgid.text = "alex:100000:65536";
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
      videoDrivers = [ "nvidia" ];

      displayManager.gdm = {
        autoSuspend = false;
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

    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
      SUBSYSTEM=="usb", ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
    '';

    tcsd.enable = true;
  };

  systemd.sockets.libvirtd-tcp.wantedBy = [ "sockets.target" ];

  virtualisation = {
    docker = {
      autoPrune.enable = true;
      enable           = true;
      storageDriver    = "btrfs";
    };

    libvirtd = {
      enable     = true;
      onShutdown = "shutdown";
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
