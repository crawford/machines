{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  nix.maxJobs = 4;

  nixpkgs.config.virtualbox.enableExtensionPack = true;

  boot.loader = {
    systemd-boot.enable      = true;
    efi.canTouchEfiVariables = true;
    timeout                  = 1;
  };

  networking.hostName = "pepcon";

  services = {
    udev.extraRules = ''
      ATTR{idVendor}=="1366", ATTR{idProduct}=="1010", MODE="0666"
      ATTR{idVendor}=="1366", ATTR{idProduct}=="1015", MODE="0666"
      KERNEL=="hidraw*", ATTRS{idVendor}=="c251", ATTRS{idProduct}=="f001", MODE="0666"
    '';

    xserver = {
      desktopManager.xterm.enable  = false;
      windowManager.awesome.enable = true;

      displayManager = {
        defaultSession = "none+awesome";

        lightdm = {
          enable         = true;
          greeter.enable = true;

          autoLogin = {
            enable = true;
            user   = "alex";
          };
        };
      };
    };
  };

  system.stateVersion = "20.03";
}
