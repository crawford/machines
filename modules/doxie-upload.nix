{ config, lib, options, pkgs, ... }:

let
  cfg = config.services.doxie-upload;

  doxie-upload = pkgs.rustPlatform.buildRustPackage rec {
    pname = "doxie-upload";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "crawford";
      repo = pname;
      rev = version;
      sha256 = "1bmfawjv4qqzk5gfwvj08flwzyvir9lhv1pcvzajcg9dbyzphz7f";
    };

    cargoSha256 = "142dlwjqbgfxfy28irqizbl8p29g2iirczdspp1bd1zqj1n6ddgn";

    meta = {
      description = "A simple file upload server compatible with Doxie scanners";
      homepage = "https://github.com/crawford/doxie-upload";
      changelog = "https://github.com/crawford/doxie-upload/raw/${version}/CHANGELOG.md";
      license = [ lib.licenses.asl20 ];
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
      script     = "${doxie-upload}/bin/doxie-upload $@";
      scriptArgs = "--port=80 --address=${cfg.address} --root=${cfg.root} ${cfg.verbosity}";
      wantedBy   = [ "multi-user.target" ];
    };
  };
}
