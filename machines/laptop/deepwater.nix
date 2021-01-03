{ config, pkgs, ... }:

{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x250>
    ./.
    ../../modules/rust.nix
    ../../modules/xfce.nix
  ];

  boot = {
    extraModprobeConfig = "options iwlwifi 11n_disable=1 wd_disable=1";

    loader = {
      grub.enable              = false;
      systemd-boot.enable      = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName              = "deepwater";
    networkmanager.enable = true;
  };

  hardware = {
    bluetooth.enable = true;

    pulseaudio = {
      enable       = true;
      package      = pkgs.pulseaudioFull;
      support32Bit = true;
    };

    sane = {
      enable        = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };
  };

  powerManagement.powertop.enable = true;

  programs = {
    zsh.promptColor = "blue";

    wireshark = {
      enable  = true;
      package = pkgs.wireshark-qt;
    };
  };

  services = {
    avahi = {
      enable  = true;
      nssmdns = true;
    };

    printing.enable = true;
  };

  users.users.alex.extraGroups = [ "wireshark" ];

  virtualisation = {
    podman.enable = true;

    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
    };
  };

  system.stateVersion = "20.09";
}
