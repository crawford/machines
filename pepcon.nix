{ pkgs, ... }:

{
  imports = [
    ./.
    modules/awesome.nix
    modules/rust.nix
  ];

  boot.loader = {
    systemd-boot.enable      = true;
    efi.canTouchEfiVariables = true;
  };

  environment.shellAliases.tmux = "tmux -2";
  programs.zsh.promptColor      = "#ff8700";

  environment.systemPackages = with pkgs; [
    libusb
    pkg-config
  ];

  networking = {
    hostName = "pepcon";
    interfaces.enp0s8.ipv4.addresses = [{
      address = "172.20.1.1";
      prefixLength = 24;
    }];
  };

  services = {
    dhcpd4 = {
      enable     = true;
      interfaces = [ "enp0s8" ];

      extraConfig = ''
        option routers 172.20.1.1;
        subnet 172.20.1.0 netmask 255.255.255.0 {
          range 172.20.1.32 172.20.1.64;
        }
      '';
    };

    udev.extraRules = ''
      ATTR{idVendor}=="1366", ATTR{idProduct}=="1010", MODE="0666"
      ATTR{idVendor}=="1366", ATTR{idProduct}=="1015", MODE="0666"
      KERNEL=="hidraw*", ATTRS{idVendor}=="c251", ATTRS{idProduct}=="f001", MODE="0666"
    '';

    xserver.displayManager.autoLogin = {
      enable = true;
      user   = "alex";
    };
  };

  system.stateVersion = "20.09";

  virtualisation.virtualbox.guest.enable = true;
}
