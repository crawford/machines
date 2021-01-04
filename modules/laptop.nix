{ pkgs, ...}:

{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub.enable              = false;
    systemd-boot.enable      = true;
  };

  hardware = {
    bluetooth.enable = true;

    pulseaudio = {
      enable  = true;
      package = pkgs.pulseaudioFull;
    };
  };

  networking.networkmanager.enable = true;
  powerManagement.powertop.enable  = true;
}
