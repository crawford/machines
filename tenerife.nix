{ config, lib, ... }:

{
  imports = [
    modules/common.nix
    modules/matrix.nix
    modules/server.nix
    modules/where.nix
  ];

  config = {
    boot.loader.timeout = lib.mkForce 10;

    console.keyMap = "us";

    networking.hostName = "tenerife";

    nix.gc.options = lib.mkForce "--delete-older-than 7d";

    programs.zsh.promptColor = "yellow";

    services = {
      do-agent.enable = true;

      nginx.virtualHosts."${config.networking.domain}".locations = {
        "/".return = "301 https://www.${config.networking.domain}$request_uri";
      };
    };

    zramSwap = {
      enable        = true;
      memoryPercent = 100;
    };
  };
}
