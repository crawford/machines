{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x250>
    ./.
    modules/btrfs.nix
    modules/gnome.nix
    modules/laptop.nix
    modules/redhat.nix
    modules/rust.nix
  ];

  networking.hostName      = "albert";
  programs.zsh.promptColor = "magenta";

  system.stateVersion = "20.03";

  virtualisation.podman.enable = true;
}
