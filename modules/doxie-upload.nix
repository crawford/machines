{ config, lib, options, pkgs, ... }:

let
  cfg = config.services.doxie-upload;

  doxie-upload = pkgs.rustPlatform.buildRustPackage rec {
    pname = "doxie-upload";
    version = "0.2.0";

    src = pkgs.fetchFromGitHub {
      owner  = "crawford";
      repo   = pname;
      rev    = version;
      sha256 = "sha256-RiUbl3gZK2CMPUntzA0mPCokskQb4YfduCrat4/Pllc=";
    };

    cargoHash = "sha256-Hlbm84m8g1evgp8dX3YB7UnC9mOXVQfGY1Qed/9wgc8=";

    meta = {
      description = "A simple file upload server compatible with Doxie scanners";
      homepage    = "https://github.com/crawford/doxie-upload";
      changelog   = "https://github.com/crawford/doxie-upload/raw/${version}/CHANGELOG.md";
      license     = [ lib.licenses.asl20 ];
    };
  };
in {
  options.services.doxie-upload = {
    address = lib.mkOption {
      default     = "0.0.0.0";
      description = "Address on which to listen for connections";
      type        = lib.types.str;
    };

    enable = lib.mkOption {
      default     = true;
      description = "Enable Doxie Upload";
      type        = lib.types.bool;
    };

    port = lib.mkOption {
      default     = true;
      description = "Port on which to listen for connections";
      type        = lib.types.port;
    };

    root = lib.mkOption {
      description = "Directory in which uploaded scans are saved";
      type        = lib.types.path;
    };

    verbosity = lib.mkOption {
      description = "Verbosity flags";
      type        = lib.types.str;
    };
  };

  config = {
    nixpkgs.config.packageOverrides = pkgs: { doxie-upload = doxie-upload; };
  } // lib.mkIf cfg.enable {
    environment.systemPackages = [ doxie-upload ];

    systemd.services."doxie-upload" = {
      wantedBy = [ "multi-user.target" ];

      unitConfig.RequiresMountsFor = cfg.root;

      serviceConfig.ExecStart = ''
        ${doxie-upload}/bin/doxie-upload --port=${toString cfg.port} --address=${cfg.address} --root=${cfg.root} ${cfg.verbosity}
      '';
    };
  };
}
