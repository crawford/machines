{ config, lib, ... }:

let cfg = config.eschede;
in {
  options.eschede = {
    domain = lib.mkOption {
      description = ''
        The DNS domain of the proxy.
      '';
    };

    hostmap = lib.mkOption {
      description = ''
        The map of publicly resolvable domain names (FQDN) to their respective backends.
      '';
    };

    upstreams = lib.mkOption {
      description = ''
        The services.nginx.upstreams object to be used.
      '';
    };
  };

  config = {
    boot = {
      cleanTmpDir = true;

      loader = {
        timeout = 1;

        grub = {
          enable  = true;
          version = 2;
          device  = "/dev/vda";
        };
      };
    };

    networking = {
      hostName                = "eschede";
      interfaces.ens3.useDHCP = true;
      useDHCP                 = false;
    };

    nix = {
      autoOptimiseStore = true;

      gc = {
        automatic = true;
        options   = "--delete-older-than 30d";
      };
    };

    programs = {
      iftop.enable = true;
      iotop.enable = true;
    };

    security.acme.acceptTerms = true;

    services = {
      sshguard.enable = true;

      nginx = {
        clientMaxBodySize        = "0";
        enable                   = true;
        enableReload             = true;
        eventsConfig             = "worker_connections 1024;";
        recommendedOptimisation  = true;
        recommendedProxySettings = true;
        recommendedTlsSettings   = true;
        upstreams                = cfg.upstreams;

        commonHttpConfig = ''
          map $host $name {
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (hostname: backend: "${hostname} ${backend};") cfg.hostmap)}
          }
        '';

        virtualHosts."eschede.${cfg.domain}" = {
          enableACME = true;
          forceSSL   = true;

          listen = [
            { addr = "0.0.0.0"; port = 80; }
            { addr = "0.0.0.0"; port = 443; ssl = true;  }
          ];

          locations."/" = {
            proxyPass       = "https://$name";
            proxyWebsockets = true;
          };

          serverAliases = builtins.filter (hostname: hostname != "-") (builtins.attrNames cfg.hostmap);
        };
      };

      openssh = {
        enable          = true;
        permitRootLogin = "yes";
      };
    };

    system = {
      stateVersion = "20.03";

      autoUpgrade = {
        allowReboot = true;
        enable      = true;
      };
    };

    time.timeZone = "US/Pacific";
  };
}
