{ lib, pkgs, ... }:

{
  imports = [
    <nixos-hardware/microsoft/surface>
    <machines/modules/alacritty.nix>
    <machines/modules/btrfs.nix>
    <machines/modules/common.nix>
    <machines/modules/gnome.nix>
    <machines/modules/udev.nix>
  ];

  boot = {
    plymouth.enable = true;

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 2;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  console.keyMap =  "us";

  environment = {
    systemPackages = with pkgs; [ firefox-wayland ];

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "titanic";

  programs.ssh.startAgent = true;
}

