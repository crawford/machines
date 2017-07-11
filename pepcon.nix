{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable      = true;
    efi.canTouchEfiVariables = true;
    timeout                  = 1;
  };

  networking.hostName = "pepcon";

  i18n = {
    consoleFont   = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "US/Pacific";

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    (import ./vim_config.nix)
    file
    gcc
    gcc-arm-embedded
    gnumake
    git
    patchelf
    tmux
    usbutils
    vim
    wget
    zsh
  ];

  services = {
    sshd.enable = true;

    xserver = {
      enable     = true;
      layout     = "us";
      xkbVariant = "dvp";
      xkbOptions = "ctrl:nocaps";

      desktopManager.xterm.enable = false;

      displayManager.slim = {
        enable      = true;
        defaultUser = "alex";
        autoLogin   = true;
      };

      windowManager = {
        awesome.enable = true;
        default        = "awesome";
      };
    };

    udev.extraRules = ''
      ATTR{idVendor}=="1366", ATTR{idProduct}=="1010", MODE="0666"
      KERNEL=="hidraw*", ATTRS{idVendor}=="c251", ATTRS{idProduct}=="f001", MODE="0666"
    '';
  };

  users.extraUsers.alex = {
    isNormalUser = true;
    extraGroups  = [ "wheel" ];
    shell        = "${pkgs.zsh}/bin/zsh";
  };
}
