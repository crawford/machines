{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./redhat-config.nix
    ./rust.nix
  ];

  boot.loader = {
    grub.enable              = false;
    systemd-boot.enable      = true;
    efi.canTouchEfiVariables = true;
  };

  hardware = {
    bluetooth.enable   = true;
    enableAllFirmware  = true;

    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
  };

  networking = {
    hostName              = "albert";
    networkmanager.enable = true;
  };

  powerManagement.powertop.enable = true;

  programs.zsh.promptColor = "magenta";

  services = {
    btrfs.autoScrub.enable = true;
    fwupd.enable           = true;

    printing = {
      drivers = [ pkgs.gutenprint pkgs.hplip ];
      enable  = true;
    };

    xserver = {
      enable = true;

      displayManager.gdm.enable    = true;
      desktopManager.gnome3.enable = true;
      desktopManager.xterm.enable  = false;
    };
  };

  system.stateVersion = "20.03";

  users.extraUsers.alex.extraGroups = [ "wheel" "plugdev" ];

  virtualisation.podman.enable = true;
}
