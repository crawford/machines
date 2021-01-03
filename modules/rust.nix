{ config, pkgs, ... }:

{
  environment = {
    shellInit = ''
      export RUSTC_WRAPPER=sccache
      export PATH=$PATH:~/.cargo/bin
    '';

    systemPackages = with pkgs; [
      rustup
      sccache
    ];
  };
}
