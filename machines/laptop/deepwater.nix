{ config, pkgs, ... }:

{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x250>
    ./.
    ../../modules/rust.nix
    ../../modules/xfce.nix
  ];

  networking.hostName = "deepwater";

  hardware.sane = {
    enable        = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  programs = {
    zsh.promptColor = "blue";

    wireshark = {
      enable  = true;
      package = pkgs.wireshark-qt;
    };
  };

  services = {
    avahi = {
      enable  = true;
      nssmdns = true;
    };

    printing.enable = true;
  };

  system.stateVersion = "20.09";
  users.users.alex.extraGroups = [ "wireshark" ];

  virtualisation = {
    podman.enable = true;

    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
    };
  };
}
