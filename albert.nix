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

  environment.etc = {
    subuid.text = "alex:100000:65536";
    subgid.text = "alex:100000:65536";
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

    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
      SUBSYSTEM=="usb", ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
    '';

    xserver = {
      enable = true;

      displayManager.gdm.enable    = true;
      desktopManager.gnome3.enable = true;
      desktopManager.xterm.enable  = false;
    };
  };

  system.stateVersion = "20.03";

  users.extraUsers.alex.extraGroups = [ "wheel" "plugdev" ];
}
