{ pkgs, ... }:

{
  imports = [
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc>
    <nixos-hardware/common/pc/ssd>
    modules/btrfs.nix
    modules/common.nix
    modules/gnome.nix
    modules/linker.nix
    modules/printer.nix
    modules/redhat.nix
    modules/rust.nix
    modules/server.nix
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

  nixpkgs.config.allowUnfree = true;

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
    xserver = {
      videoDrivers = [ "nvidia" ];

      displayManager.gdm = {
        autoSuspend = false;
        wayland     = false;
      };
    };

    avahi = {
      enable   = true;
      nssmdns  = true;
    };

    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
      SUBSYSTEM=="usb", ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
    '';

    tcsd.enable = true;
  };

  systemd.sockets.libvirtd-tcp.wantedBy = [ "sockets.target" ];

  virtualisation = {
    podman.enable = true;

    libvirtd = {
      enable     = true;
      onShutdown = "shutdown";
    };
  };

  users.extraUsers = {
    aaron.shell      = "${pkgs.bashInteractive}/bin/bash";
    adahiya          = {};
    alex.extraGroups = [ "libvirtd" ];
  };

  system.stateVersion = "20.09";
}
