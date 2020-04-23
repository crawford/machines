{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  nix.maxJobs = 4;

  boot = {
    extraModprobeConfig = "options iwlwifi 11n_disable=1 wd_disable=1";

    loader = {
      grub.enable              = false;
      systemd-boot.enable      = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName              = "deepwater";
    networkmanager.enable = true;
  };

  hardware = {
    bluetooth.enable              = true;
    enableRedistributableFirmware = true;
    opengl.driSupport32Bit        = true;

    pulseaudio = {
      enable       = true;
      package      = pkgs.pulseaudioFull;
      support32Bit = true;
    };

    sane = {
      enable        = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };
  };

  programs.zsh.promptColor = "blue";

  services = {
    avahi = {
      enable  = true;
      nssmdns = true;
    };

    printing.enable = true;

    xserver = {
      desktopManager.gnome3.enable = true;
      desktopManager.xterm.enable  = false;
      displayManager.gdm.enable    = true;
      synaptics.enable             = false;
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
    };
  };

  system.stateVersion = "20.03";
}
