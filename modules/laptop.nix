{ pkgs, ...}:

{
  imports = [
    ./printer.nix
  ];

  boot = {
    extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
    '';

    loader = {
      efi.canTouchEfiVariables = true;
      grub.enable              = false;
      systemd-boot.enable      = true;
    };
  };

  hardware = {
    bluetooth.enable = true;

    opengl.extraPackages = [ pkgs.vaapiIntel ];

    pulseaudio = {
      enable  = true;
      package = pkgs.pulseaudioFull;
    };
  };

  networking.networkmanager.enable = true;
  powerManagement.powertop.enable  = true;
  services.acpid.enable            = true;
  services.fwupd.enable            = true;
  services.thinkfan.enable         = true;
}
