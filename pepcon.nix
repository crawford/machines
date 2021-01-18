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
  networking.hostName           = "pepcon";
  programs.zsh.promptColor      = "#ff8700";

  environment.systemPackages = with pkgs; [
    libusb
    pkg-config
  ];

  services = {
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
