{ config, lib, ... }:

let
  domain = config.networking.domain;
in
{
  config.services.nginx = {
    enable = true;

    recommendedTlsSettings   = true;
    recommendedOptimisation  = true;
    recommendedGzipSettings  = true;
    recommendedProxySettings = true;

    virtualHosts."where.${domain}" = {
      addSSL     = true;
      enableACME = true;

      locations."/".proxyPass = "http://[::1]:8080";
    };
  };
}
