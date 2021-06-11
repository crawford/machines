{ fetchFromGitHub, lib, nodejs, pkgs, stdenv, ... }:

let
  src = fetchFromGitHub {
    owner = "zwave-js";
    repo = "zwave-js-server";
    rev = "1.7.0";
    sha256 = "0ya4l7nis5ch2iv0slvcjgh97w870jf3y8dlws53vy5k6m4i5ns1";
  };

  nodePackages = import ./composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in nodePackages.package.override {
  inherit src;

  buildInputs = [ pkgs.nodePackages.typescript ];

  preRebuild = ''
    npm run build
  '';

  meta = with lib; {
    description = "Small server wrapper around Z-Wave JS to access it via a WebSocket";
    maintainers = with maintainers; [ ];
    license = licenses.asl20;
  };
}
