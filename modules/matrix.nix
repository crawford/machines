{ config, pkgs, ... }:

let
  coturn = config.services.coturn;
  domain = config.networking.domain;
in
{
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
      coturn.tls-listening-port
      (coturn.tls-listening-port + 1)
    ];

    allowedUDPPortRanges = [{
      from = coturn.min-port;
      to   = coturn.max-port;
    }];
  };

  security.acme = {
    acceptTerms = true;

    certs."turn.${domain}" = {
      group   = "nginx";
      postRun = "systemctl reload nginx.service; systemctl restart coturn.service";
    };
  };

  services = {
    coturn = {
      enable       = true;
      lt-cred-mech = true;
      no-cli       = true;
      realm        = "turn.${domain}";
      secure-stun  = true;

      static-auth-secret = config.services.matrix-synapse.turn_shared_secret;
      use-auth-secret    = true;

      cert = "/var/lib/acme/turn.${domain}/fullchain.pem";
      pkey = "/var/lib/acme/turn.${domain}/key.pem";

      extraConfig = ''
        cipher-list="HIGH"
        no-loopback-peers
        no-multicast-peers
      '';
    };

    matrix-synapse = {
      database_type   = "sqlite3";
      enable          = true;
      max_upload_size = "50M";
      server_name     = domain;

      turn_uris = [
        "turn:turn.${domain}:${builtins.toString coturn.tls-listening-port}?transport=udp"
        "turn:turn.${domain}:${builtins.toString coturn.tls-listening-port}?transport=tcp"
        "turn:turn.${domain}:${builtins.toString (coturn.tls-listening-port + 1)}?transport=udp"
        "turn:turn.${domain}:${builtins.toString (coturn.tls-listening-port + 1)}?transport=tcp"
      ];

      listeners = [{
        bind_address = "::1";
        port         = 8448;
        tls          = false;
        x_forwarded  = true;

        resources = [
          {
            names    = [ "client" "webclient" ];
            compress = true;
          }
          {
            names    = [ "federation" ];
            compress = false;
          }
        ];
      }];
    };

    nginx = {
      enable                   = true;
      recommendedTlsSettings   = true;
      recommendedOptimisation  = true;
      recommendedGzipSettings  = true;
      recommendedProxySettings = true;

      virtualHosts = {
        "matrix.${domain}" = {
          enableACME = true;
          forceSSL   = true;

          locations = {
            "/".return           = "404";
            "/_matrix".proxyPass = "http://[::1]:8448";
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
}
