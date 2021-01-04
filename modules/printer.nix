{ pkgs, ... }:

{
  hardware.sane = {
    enable        = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  services = {
    printing = {
      drivers = [ pkgs.gutenprint pkgs.hplip ];
      enable  = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
