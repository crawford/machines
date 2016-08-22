{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      bluez = pkgs.bluez5;
    };
    vim.ftNixSupport = true;
    chromium.enableWideVine = true;
  };

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/3a5ef679-5528-40bf-aeaa-cb99bc647b4e";
    }
  ];

  boot.loader.grub.enable = false;
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "neil";

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  i18n = {
    consoleFont   = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "US/Pacific";

  security.sudo.wheelNeedsPassword = false;

  environment = {
    shells = [ "${pkgs.zsh}/bin/zsh" ];

    sessionVariables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      chromium
      gcc
      gcc-arm-embedded
      git
      gnumake
      kicad
      mutt
      patchelf
      qt55.full
      rustc
      spotify
      tightvnc
      tmux
      usbutils
      vim
      vimPlugins.vundle
      wings
      wget
      xorg.xmodmap
    ];
  };

  programs.zsh.enable = true;

  services.xserver = {
    enable     = true;
    layout     = "us";
    xkbVariant = "dvp";
    xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";

    desktopManager.gnome3.enable = true;
    desktopManager.xterm.enable = false;

    displayManager.gdm.enable = true;
  };

  services.udev.extraRules = ''
    ATTRS{idVendor}=="2544", ATTRS{idProduct}=="0002", MODE="666"
  '';

  users.extraUsers.alex = {
    name       = "alex";
    group      = "wheel";
    createHome = true;
    home       = "/home/alex";
    shell      = "/run/current-system/sw/bin/zsh";
  };

  system.stateVersion = "16.03";
}
