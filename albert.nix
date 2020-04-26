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

  networking = {
    hostName              = "albert";
    networkmanager.enable = true;
  };

  hardware = {
    bluetooth.enable   = true;
    enableAllFirmware  = true;
    pulseaudio.enable  = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  programs.zsh.promptColor = "magenta";

  services = {
    btrfs.autoScrub.enable = true;
    fwupd.enable           = true;

    printing = {
      drivers = [ pkgs.gutenprint pkgs.hplip ];
      enable  = true;
    };

    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
      SUBSYSTEM=="usb", ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
    '';

    xserver = {
      displayManager.gdm.enable    = true;
      desktopManager.gnome3.enable = true;
    };
  };

  users.extraUsers.alex.extraGroups = [ "wheel" "plugdev" ];

  system.stateVersion = "20.03";
}
