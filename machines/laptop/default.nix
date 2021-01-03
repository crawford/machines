{ pkgs, ...}:

{
  imports = [ ../. ];

  boot.loader = {
    grub.enable              = false;
    systemd-boot.enable      = true;
    efi.canTouchEfiVariables = true;
  };

  hardware = {
    bluetooth.enable   = true;
    enableAllFirmware  = true;

    pulseaudio = {
      enable  = true;
      package = pkgs.pulseaudioFull;
    };
  };

  networking.networkmanager.enable = true;
  powerManagement.powertop.enable  = true;
}
