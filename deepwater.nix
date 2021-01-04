{ config, pkgs, ... }:

{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x250>
    ./.
    modules/laptop.nix
    modules/rust.nix
    modules/wireshark.nix
    modules/xfce.nix
  ];

  networking.hostName      = "deepwater";
  programs.zsh.promptColor = "blue";

  services.avahi = {
    enable  = true;
    nssmdns = true;
  };

  system.stateVersion = "20.09";

  virtualisation = {
    podman.enable = true;

    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
    };
  };
}
