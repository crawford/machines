{ config, pkgs, ... }:

let
  coturn = config.services.coturn;
  domain = config.networking.domain;
in
{
  environment.systemPackages = with pkgs; [
    mautrix-signal
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

    certs."turn.${domain}" = {
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

      cert = "/var/lib/acme/turn.${domain}/fullchain.pem";
      pkey = "/var/lib/acme/turn.${domain}/key.pem";

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
        database.name   = "sqlite3";
        max_upload_size = "50M";
        server_name     = domain;

        suppress_key_server_warning = true;

        extraConfigFiles = [ "/var/lib/matrix-synapse/secrets.conf" ];

        app_service_config_files = [
          "/var/lib/matrix-synapse/signal-registration.yaml"
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
          "turn:turn.${domain}:${builtins.toString coturn.tls-listening-port}?transport=udp"
          "turn:turn.${domain}:${builtins.toString coturn.tls-listening-port}?transport=tcp"
          "turn:turn.${domain}:${builtins.toString (coturn.tls-listening-port + 1)}?transport=udp"
          "turn:turn.${domain}:${builtins.toString (coturn.tls-listening-port + 1)}?transport=tcp"
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

        "turn.${domain}" = {
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
  };

  systemd.services.mautrix-signal = {
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

  users.users = {
    mautrix-signal = {
      createHome   = true;
      group        = "nogroup";
      extraGroups  = [ "signald" ];
      home         = "/var/lib/mautrix-signal";
      isSystemUser = true;
    };

    turnserver.extraGroups = [ "nginx" ];
  };
}
