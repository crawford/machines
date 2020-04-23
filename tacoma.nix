{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ];

  boot = {
    loader.timeout = 1;
    kernelParams = [ "console=ttyS1,115200n8" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  docker-containers.pihole = {
    image = "pihole/pihole:latest";
    environment = {
      TZ = "US/Pacific";
      # WEBPASSWORD = "";
      # ServerIP = "";
      DNSMASQ_LISTENING = "all";
      # DNS1 = "";
      # DNS2 = "";
      CONDITIONAL_FORWARDING = "True";
      # CONDITIONAL_FORWARDING_IP = "";
      # CONDITIONAL_FORWARDING_DOMAIN = "";
      # CONDITIONAL_FORWARDING_REVERSE = "";
    };
    volumes = [
      "/var/lib/pihole/dnsmasq.d/:/etc/dnsmasq.d/"
      "/var/lib/pihole/pihole/:/etc/pihole/"
    ];
    ports = [
      # ""
      # ""
      # ""
      # ""
    ];
    extraDockerOptions = [
      "--dns=127.0.0.1"
    ];
  };

  fileSystems."/mnt/valdez/media" = {
    device = "//valdez/Media/";
    fsType = "cifs";

    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "credentials=/etc/nixos/smb-secrets"
    ];
  };

  networking = {
    hostName = "tacoma";
    useDHCP  = false;

    bonds.uplink = {
      driverOptions.mode = "active-backup";
      interfaces         = [ "eno1" "eno2" ];
    };

    defaultGateway = {
      # address = "";
      # interface = "";
    };

    interfaces.uplink.ipv4.addresses = [
      # { address = ""; prefixLength = ; }
    ];

    # vlans.dmz = {
    #   id        = ;
    #   interface = "";
    # };
  };

  programs.zsh.promptColor = "0;31";

  services = {
    btrfs.autoScrub.enable = true;
    fwupd.enable           = true;

    plex = {
      enable        = true;
      managePlugins = false;
    };

    unifi = {
      enable       = true;
      unifiPackage = pkgs.unifi;
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemuRunAsRoot = false;
  };

  users.users.alex.extraGroups = [ "wheel" "libvirtd" ];

  system = {
    stateVersion = "20.03";

    autoUpgrade = {
      allowReboot = true;
      enable      = true;
    };
  };
}
