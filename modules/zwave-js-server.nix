{ config, lib, options, pkgs, ... }:

let
  cfg = config.services.zwave-js-server;

  zwave-js-server = pkgs.callPackage ../packages/zwave-js-server {};
in {
  options.services.zwave-js-server = {
    devicePath = lib.mkOption {
      default     = "/dev/ttyACM0";
      description = "Path of the serial device exposed by the dongle";
      type        = lib.types.str;
    };

    enable = lib.mkOption {
      default     = true;
      description = "Enable ZWave Server";
      type        = lib.types.bool;
    };

    networkKey = lib.mkOption {
      default     = null;
      description = "16-byte network key, specified as `0xAB, 0xCD, ...` or `ABCD...`";
      type        = lib.types.str;
    };

    port = lib.mkOption {
      default     = 3000;
      description = "Port on which to listen for WebSocket connections";
      type        = lib.types.port;
    };
  };

  config = {
    nixpkgs.config.packageOverrides = pkgs: { zwave-js-server = zwave-js-server; };
  } // lib.mkIf cfg.enable {
    environment.systemPackages = [ zwave-js-server ];

    systemd.services."zwave-js-server" = let
      config = (pkgs.writeTextFile {
        name = "zwave-js-config";

        text = ''
          module.exports = {
            "networkKey": "${cfg.networkKey}",
            "storage": {
              "cacheDir": "/var/lib/zwave-js/cache"
            }
          };
        '';
      });
    in {
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User  = "zwavejs";
        Group = "nogroup";

        Environment = "ZWAVEJS_EXTERNAL_CONFIG=/var/lib/zwave-js/state";

        PermissionsStartOnly = true;
        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/zwave-js/cache /var/lib/zwave-js/state"
          "${pkgs.coreutils}/bin/chown -R zwavejs /var/lib/zwave-js"
        ];

        ExecStart = "${zwave-js-server}/bin/zwave-server ${cfg.devicePath} --port ${toString cfg.port} --config ${config}";
      };
    };

    users.users.zwavejs = {
      createHome   = false;
      extraGroups  = [ "dialout" ];
      isNormalUser = true;
    };
  };
}
