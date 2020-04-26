{ config, pkgs, ... }:

{
  environment = {
    shellInit = "export RUSTC_WRAPPER=sccache";

    systemPackages = with pkgs; [
      rustup
      sccache
    ];
  };
}
