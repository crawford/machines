{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./rust.nix
  ];

  environment.shellAliases.tmux          = "tmux -2";
  networking.hostName                    = "pepcon";
  nix.maxJobs                            = 4;
  virtualisation.virtualbox.guest.enable = true;
  programs.zsh.promptColor               = "#ff8700";

  boot.loader = {
    systemd-boot.enable      = true;
    efi.canTouchEfiVariables = true;
    timeout                  = 1;
  };

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
