{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable  = true;
    version = 2;
    device = "/dev/vda";
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
    wget
    vim
    rustc
    xorg.xmodmap
    zsh
  ];

  environment.shells = [
    "${pkgs.zsh}/bin/zsh"
  ];

  services.xserver = {
    enable     = true;
    layout     = "us";
    xkbVariant = "dvp";
    xkbOptions = "ctrl:nocaps";

    desktopManager.default = "none";

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

  users.extraUsers.alex = {
    name       = "alex";
    group      = "wheel";
    uid        = 1000;
    createHome = true;
    home       = "/home/alex";
    shell      = "${pkgs.zsh}/bin/zsh";
  };

  system.stateVersion = "15.09";
}
