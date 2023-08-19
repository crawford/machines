{ config, pkgs, ... }:

let
  coturn = config.services.coturn;
  domain = config.networking.domain;
in
{
  environment.systemPackages = with pkgs; [
    mautrix-signal
    mautrix-whatsapp
  ];

  networking.firewall = let
    coturnRange = {
      from = coturn.min-port;
      to   = coturn.max-port;
    };
    coturnListeningPorts = [
      coturn.listening-port
      coturn.alt-listening-port
      coturn.tls-listening-port
      coturn.alt-tls-listening-port
    ];
  in
    {
      allowedUDPPorts = coturnListeningPorts;
      allowedTCPPorts = coturnListeningPorts ++ [
        80
        443
      ];

      allowedUDPPortRanges = [ coturnRange ];
    };

  security.acme = {
    acceptTerms = true;

    certs."${coturn.realm}" = {
      group   = "nginx";
      postRun = "systemctl reload nginx.service; systemctl restart coturn.service";
    };
  };

  services = {
    signald.enable = true;

    coturn = {
      enable       = true;
      no-cli       = true;
      no-tcp-relay = true;
      realm        = "turn.${domain}";
      secure-stun  = true;

      min-port = 49000;
      max-port = 50000;

      static-auth-secret = config.services.matrix-synapse.settings.turn_shared_secret;
      use-auth-secret    = true;

      cert = "/var/lib/acme/${coturn.realm}/fullchain.pem";
      pkey = "/var/lib/acme/${coturn.realm}/key.pem";

      extraConfig = ''
        cipher-list="HIGH"
        no-multicast-peers

        denied-peer-ip=0.0.0.0-0.255.255.255
        denied-peer-ip=100.64.0.0-100.127.255.255
        denied-peer-ip=127.0.0.0-127.255.255.255
        denied-peer-ip=169.254.0.0-169.254.255.255
        denied-peer-ip=192.0.0.0-192.0.0.255
        denied-peer-ip=192.0.2.0-192.0.2.255
        denied-peer-ip=192.88.99.0-192.88.99.255
        denied-peer-ip=198.18.0.0-198.19.255.255
        denied-peer-ip=198.51.100.0-198.51.100.255
        denied-peer-ip=203.0.113.0-203.0.113.255
        denied-peer-ip=240.0.0.0-255.255.255.255
      '';
    };

    matrix-synapse = {
      enable = true;

      settings = {
        database = {
          name      = "psycopg2";
          args.user = "matrix-synapse";
        };

        max_upload_size = "50M";
        server_name     = domain;

        suppress_key_server_warning = true;

        extraConfigFiles = [ "/var/lib/matrix-synapse/secrets.conf" ];

        app_service_config_files = [
          "/var/lib/matrix-synapse/signal-registration.yaml"
          "/var/lib/matrix-synapse/whatsapp-registration.yaml"
        ];

        listeners = [{
          bind_addresses = [ "::1" ];
          port         = 8448;
          tls          = false;
          x_forwarded  = true;

          resources = [
            {
              names    = [ "client" ];
              compress = true;
            }
            {
              names    = [ "federation" ];
              compress = false;
            }
          ];
        }];

        turn_uris = [
          # "turns:${coturn.realm}?transport=tcp"
          # "turns:${coturn.realm}?transport=udp"
          "turn:${coturn.realm}?transport=tcp"
          "turn:${coturn.realm}?transport=udp"
        ];
      };
    };

    nginx = {
      enable                   = true;
      recommendedTlsSettings   = true;
      recommendedOptimisation  = true;
      recommendedGzipSettings  = true;
      recommendedProxySettings = true;
      clientMaxBodySize        = "0";

      virtualHosts = {
        "matrix.${domain}" = {
          enableACME = true;
          forceSSL   = true;

          locations = {
            "/".return = "404";

            "/_matrix".proxyPass         = "http://[::1]:8448";
            "/_synapse/client".proxyPass = "http://[::1]:8448";
          };
        };

        "${coturn.realm}" = {
          enableACME = true;
          forceSSL   = true;
        };

        "${domain}" = {
          default    = true;
          enableACME = true;
          forceSSL   = true;

          locations = {
            "= /.well-known/matrix/server" = {
              extraConfig = "add_header Content-Type application/json;";

              return =
                let server = {
                  "m.server" = "matrix.${domain}:443";
                };
                in "200 '${builtins.toJSON server}'";
            };

            "= /.well-known/matrix/client" = {
              extraConfig = ''
                add_header Content-Type application/json;
                add_header Access-Control-Allow-Origin *;
              '';

              return =
                let client = {
                  "m.homeserver" = {
                    "base_url" = "https://matrix.${domain}";
                  };
                };
                in "200 '${builtins.toJSON client}'";
            };
          };
        };

        "element.${domain}" = {
          enableACME = true;
          forceSSL   = true;

          root = pkgs.element-web.override {
            conf.default_server_config."m.homeserver" = {
              "server_name" = domain;
            };
          };
        };
      };
    };

    postgresql = let
      conn = config.services.matrix-synapse.settings.database.args;
    in
    {
      enable  = true;
      package = pkgs.postgresql_14;

      initialScript = pkgs.writeText "matrix-init" ''
        CREATE DATABASE "${conn.database}"
          OWNER "${conn.user}"
          ENCODING 'UTF8'
          TEMPLATE template0
          LC_COLLATE 'C'
          LC_CTYPE 'C';
        CREATE USER "${conn.user}";
        GRANT ALL PRIVILEGES ON DATABASE "${conn.database}" TO "${conn.user}";
      '';
    };
  };

  systemd.services = {
    mautrix-signal = {
      description = "mautrix-signal bridge";
      enable      = true;

      after    = [ "matrix-synapse.service" "signald.service" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig.JoinsNamespaceOf = "signald.service";

      serviceConfig = {
        ExecStart        = "${pkgs.mautrix-signal}/bin/mautrix-signal";
        PrivateTmp       = true;
        User             = "mautrix-signal";
        WorkingDirectory = "~";
      };
    };

    mautrix-whatsapp = {
      description = "mautrix-whatsapp bridge";
      enable      = true;

      after    = [ "matrix-synapse.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart        = "${pkgs.mautrix-whatsapp}/bin/mautrix-whatsapp";
        User             = "mautrix-whatsapp";
        WorkingDirectory = "~";
        Restart          = "on-failure";
        RestartSec       = "30s";

        ReadWritePaths          = "/var/lib/mautrix-whatsapp";
        NoNewPrivileges         = true;
        MemoryDenyWriteExecute  = true;
        PrivateDevices          = true;
        PrivateTmp              = true;
        ProtectHome             = true;
        ProtectSystem           = "strict";
        ProtectControlGroups    = true;
        RestrictSUIDSGID        = true;
        RestrictRealtime        = true;
        LockPersonality         = true;
        ProtectKernelLogs       = true;
        ProtectKernelTunables   = true;
        ProtectHostname         = true;
        ProtectKernelModules    = true;
        PrivateUsers            = true;
        ProtectClock            = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber   = "EPERM";
        SystemCallFilter        = "@system-service";
      };
    };
  };

  users.users = {
    turnserver.extraGroups = [ "nginx" ];

    mautrix-signal = {
      createHome   = true;
      group        = "nogroup";
      extraGroups  = [ "signald" ];
      home         = "/var/lib/mautrix-signal";
      isSystemUser = true;
    };

    mautrix-whatsapp = {
      createHome   = true;
      group        = "nogroup";
      home         = "/var/lib/mautrix-whatsapp";
      isSystemUser = true;
    };
  };
}
