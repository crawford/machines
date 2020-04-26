{ config, lib, pkgs, ... }:

let cfg = config.tacoma;
in
{
  imports = [ ./common.nix ];

  options.tacoma = {
    dnsServers = lib.mkOption {
      description = ''
        The list of DNS servers to use for the site.
      '';
    };

    dmzId = lib.mkOption {
      description = ''
        The VLAN ID of the DMZ network.
      '';
      type = lib.types.ints.between 0 4095;
    };

    domain = lib.mkOption {
      description = ''
        The domain of the site.
      '';
    };

    gateway = lib.mkOption {
      description = ''
        The IP address of the gateway.
      '';
    };

    ipAddress = lib.mkOption {
      description = ''
        The IP address of the machine.
      '';
    };

    ipAddressPrefix = lib.mkOption {
      description = ''
        The CIDR prefix length of address of the machine.
      '';
      type = lib.types.ints.between 0 32;
    };

    piholePassword = lib.mkOption {
      description = ''
        The password of the Pi-Hole.
      '';
    };

    reverseLookupDomain = lib.mkOption {
      description = ''
        The domain to be used in reverse DNS lookups (e.g. in-addr.arpa).
      '';
    };
  };

  config = {
    boot = {
      kernelParams   = [ "console=ttyS1,115200n8" ];
      loader.timeout = 1;

      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable      = true;
      };
    };

    docker-containers.pihole = {
      image = "pihole/pihole:latest";

      environment = {
        TZ                             = "${config.time.timeZone}";
        WEBPASSWORD                    = "${cfg.piholePassword}";
        ServerIP                       = "${cfg.ipAddress}";
        DNSMASQ_LISTENING              = "all";
        DNS1                           = "${builtins.elemAt cfg.dnsServers 0}";
        DNS2                           = "${builtins.elemAt cfg.dnsServers 1}";
        CONDITIONAL_FORWARDING         = "True";
        CONDITIONAL_FORWARDING_IP      = "${cfg.gateway}";
        CONDITIONAL_FORWARDING_DOMAIN  = "${cfg.domain}";
        CONDITIONAL_FORWARDING_REVERSE = "${cfg.reverseLookupDomain}";
      };

      extraDockerOptions = [
        "--dns=127.0.0.1"
      ];

      ports = [
        "${cfg.ipAddress}:53:53/tcp"
        "${cfg.ipAddress}:53:53/udp"
        "${cfg.ipAddress}:80:80"
        "${cfg.ipAddress}:443:443"
      ];

      volumes = [
        "/var/lib/pihole/dnsmasq.d/:/etc/dnsmasq.d/"
        "/var/lib/pihole/pihole/:/etc/pihole/"
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
      domain      = "${cfg.domain}";
      hostName    = "tacoma";
      nameservers = [ "${cfg.gateway}" ];
      useDHCP     = false;

      bonds.uplink = {
        driverOptions.mode = "active-backup";
        interfaces         = [ "eno1" "eno2" ];
      };

      defaultGateway = {
        address   = "${cfg.gateway}";
        interface = "uplink";
      };

      interfaces.uplink.ipv4.addresses = [{
        address      = "${cfg.ipAddress}";
        prefixLength = cfg.ipAddressPrefix;
      }];

      vlans.dmz = {
        id        = cfg.dmzId;
        interface = "uplink";
      };
    };

    programs.zsh.promptColor = "red";

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
  };
}