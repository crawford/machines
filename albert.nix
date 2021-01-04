{ config, pkgs, ... }:

{
  imports = [
    <nixos-hardware/lenovo/x250>
    ./.
    modules/gnome.nix
    modules/laptop.nix
    modules/redhat.nix
    modules/rust.nix
  ];

  networking.hostName = "albert";

  programs.zsh.promptColor = "magenta";

  services = {
    btrfs.autoScrub.enable = true;
    fwupd.enable           = true;

    printing = {
      drivers = [ pkgs.gutenprint pkgs.hplip ];
      enable  = true;
    };
  };

  system.stateVersion = "20.03";

  virtualisation.podman.enable = true;
}
