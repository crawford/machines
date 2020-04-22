{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  nix.maxJobs = 4;

  boot = {
    extraModprobeConfig = "options iwlwifi 11n_disable=1 wd_disable=1";
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      #packages = [ pkgs.networkmanager_strongswan ];
      enableStrongSwan = true;
    };
    hostName = "deepwater";
    firewall.allowedTCPPorts = [ 12345 ];
    #firewall.allowedUDPPorts = [ 67 68 ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };
    opengl.driSupport32Bit = true;
    sane = {
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };
  };

  #time.timeZone = "America/New_York";
  #time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    gnupg
    xorg.xmodmap
  ];

  services = {
    xserver = {
      desktopManager.gnome3.enable = true;
      desktopManager.xterm.enable = false;

      displayManager.gdm.enable = true;

      synaptics.enable = false;
    };

    udev.extraRules = ''
      ATTRS{idVendor}=="2544", ATTRS{idProduct}=="0002", MODE="666"
      ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1015", GROUP="wheel", MODE="666", TAG+="uaccess"
      ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="d911", GROUP="wheel", MODE="666", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
      SUBSYSTEM=="usb", ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="wheel", TAG+="uaccess"
    '';

    avahi = {
      enable   = true;
      nssmdns  = true;
    };

    #dbus.packages = [ pkgs.strongswan ];

    printing.enable = true;

    tcsd.enable = true;
  };

  #powerManagement.powertop.enable = true;
  #system.autoUpgrade.enable = true;

  virtualisation = {
    #rkt = {
    #  enable = true;
    #  gc.automatic = true;
    #};

    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
    };

    #virtualbox.host.enable = true;
  };

  users.extraUsers.alex = {
    extraGroups = [ "wheel" "plugdev" "rkt" ];
  };

  users.extraUsers.rkt = {
    name        = "rkt";
    group       = "rkt";
    createHome  = false;
  };

  system.stateVersion = "20.03";
}
