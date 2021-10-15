{ config, lib, ... }:

{
  imports = [
    modules/common.nix
    modules/matrix.nix
    modules/server.nix
  ];

  config = {
    networking.hostName = "tenerife";

    programs.zsh.promptColor = "yellow";

    services.nginx.virtualHosts."${config.networking.domain}".locations = {
      "/".return = "301 https://www.${config.networking.domain}$request_uri";
    };

    system.autoUpgrade = {
      allowReboot = true;
      enable      = true;
    };
  };
}
