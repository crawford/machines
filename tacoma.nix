{ config, lib, pkgs, ... }:

let cfg = config.tacoma;
in
{
  imports = [
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc>
    <nixos-hardware/common/pc/hdd>
    modules/btrfs.nix
    modules/common.nix
    modules/doxie-upload.nix
    modules/server.nix
    modules/transmission.nix
  ];

  options.tacoma = {
    auxIpAddress = lib.mkOption {
      description = ''
        The auxilary IP address of the machine.
      '';
    };

    auxIpAddressPrefix = lib.mkOption {
      description = ''
        The CIDR prefix length of the auxilary address of the machine.
      '';
      type = lib.types.ints.between 0 32;
    };

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

    forwardingIp = lib.mkOption {
      description = ''
        The IP address of the DNS server to which requests will be forwarded.
      '';
    };

    gateway = lib.mkOption {
      description = ''
        The IP address of the gateway.
      '';
    };

    ipAddress = lib.mkOption {
      description = ''
        The main IP address of the machine.
      '';
    };

    ipAddressPrefix = lib.mkOption {
      description = ''
        The CIDR prefix length of the main address of the machine.
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

    serviceId = lib.mkOption {
      description = ''
        The VLAN ID of the Service network.
      '';
      type = lib.types.ints.between 0 4095;
    };
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    boot = {
      kernelParams = [ "console=ttyS1,115200n8" "mds=full,nosmt" ];

      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable      = true;
      };
    };

    fileSystems."/mnt/valdez/media" = {
      device = "//valdez.host.${cfg.domain}/Media/";
      fsType = "cifs";

      options = [
        "x-systemd.automount"
        "noauto"
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

      bridges.brdmz.interfaces = [ "dmz" ];

      defaultGateway = {
        address   = "${cfg.gateway}";
        interface = "uplink";
      };

      interfaces.uplink.ipv4.addresses = [
        {
          address      = "${cfg.ipAddress}";
          prefixLength = cfg.ipAddressPrefix;
        }
        {
          address      = "${cfg.auxIpAddress}";
          prefixLength = cfg.auxIpAddressPrefix;
        }
      ];

      vlans = {
        dmz = {
          id        = cfg.dmzId;
          interface = "uplink";
        };

        services = {
          id        = cfg.serviceId;
          interface = "uplink";
        };
      };
    };

    programs.zsh.promptColor = "red";

    services = {
      doxie-upload = {
        address   = "127.0.0.1";
        port      = 1080;
        root      = "/mnt/valdez/media/Scans";
        verbosity = "-v";
      };

      nginx = {
        clientMaxBodySize        = "0";
        enable                   = true;
        eventsConfig             = "worker_connections 1024;";
        proxyResolveWhileRunning = true;
        recommendedOptimisation  = true;
        recommendedProxySettings = true;
        recommendedTlsSettings   = true;
        resolver.addresses       = [ "${cfg.auxIpAddress}" ];

        virtualHosts."firmware.${cfg.domain}" = {
          useACMEHost = "wildcard.${cfg.domain}";

          listen = [
            { addr = cfg.ipAddress; port = 80; }
            { addr = cfg.ipAddress; port = 443; ssl = true; }
          ];

          locations."/" = {
            extraConfig = "autoindex on;";
            root        = "/mnt/valdez/media/Firmware";
          };
        };
      };

      plex = {
        enable        = true;
        managePlugins = false;
      };

      unifi = {
        enable       = true;
        unifiPackage = pkgs.unifi;
      };
    };

    security.acme.certs = {
      "wildcard.home.acrawford.com" = {
        credentialsFile = "/etc/nixos/digitalocean-secrets";
        dnsProvider     = "digitalocean";
        domain          = "*.${cfg.domain}";
        group           = config.services.nginx.user;
      };
    };

    systemd.services.plex.unitConfig.RequiresMountsFor = "/mnt/valdez/media/Media";

    virtualisation = {
      libvirtd = {
        enable        = true;
        onBoot        = "ignore";
        onShutdown    = "shutdown";

        qemu.runAsRoot = false;
      };

      oci-containers = {
        backend = "podman";

        containers = {
          pihole = {
            image = "pihole/pihole:latest";

            environment = {
              TZ                             = "${config.time.timeZone}";
              WEBPASSWORD                    = "${cfg.piholePassword}";
              ServerIP                       = "${cfg.auxIpAddress}";
              DNSMASQ_LISTENING              = "all";
              DNS1                           = "${builtins.elemAt cfg.dnsServers 0}";
              DNS2                           = "${builtins.elemAt cfg.dnsServers 1}";
              CONDITIONAL_FORWARDING         = "true";
              CONDITIONAL_FORWARDING_IP      = "${cfg.forwardingIp}";
              CONDITIONAL_FORWARDING_DOMAIN  = "${cfg.domain}";
              CONDITIONAL_FORWARDING_REVERSE = "${cfg.reverseLookupDomain}";
            };

            extraOptions = [
              "--dns=127.0.0.1"
              "--dns=172.18.16.6"
              "--no-hosts"
            ];

            ports = [
              "${cfg.auxIpAddress}:53:53/tcp"
              "${cfg.auxIpAddress}:53:53/udp"
              "${cfg.auxIpAddress}:80:80"
              "${cfg.auxIpAddress}:443:443"
            ];

            volumes = [
              "/var/lib/pihole/dnsmasq.d/:/etc/dnsmasq.d/"
              "/var/lib/pihole/pihole/:/etc/pihole/"
            ];
          };
        };
      };
    };

    users.users.alex.extraGroups = [ "libvirtd" ];

    system = {
      stateVersion = "20.09";

      autoUpgrade = {
        allowReboot = true;
        enable      = true;
      };
    };
  };
}
