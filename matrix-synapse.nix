{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme.acceptTerms = true;

  services = {
    matrix-synapse = {
      database_type   = "sqlite3";
      enable          = true;
      max_upload_size = "50M";
      server_name     = "${config.networking.domain}";

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
        "matrix.${config.networking.domain}" = {
          enableACME = true;
          forceSSL   = true;

          locations = {
            "/".return           = "404";
            "/_matrix".proxyPass = "http://[::1]:8448";
          };
        };

        "${config.networking.domain}" = {
          default    = true;
          enableACME = true;
          forceSSL   = true;

          locations = {
            "= /.well-known/matrix/server" = {
              extraConfig = "add_header Content-Type application/json;";

              return =
                let server = {
                  "m.server" = "matrix.${config.networking.domain}:443";
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
                    "base_url" = "https://matrix.${config.networking.domain}";
                  };
                };
                in "200 '${builtins.toJSON client}'";
            };
          };
        };

        "element.${config.networking.domain}" = {
          enableACME = true;
          forceSSL   = true;

          root = pkgs.element-web.override {
            conf.default_server_config."m.homeserver" = {
              "server_name" = "${config.networking.domain}";
            };
          };
        };
      };
    };
  };
}
