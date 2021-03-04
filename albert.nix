{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x250>
    ./.
    modules/btrfs.nix
    modules/gnome.nix
    modules/laptop.nix
    modules/redhat.nix
    modules/rust.nix
    modules/udev.nix
    modules/wireshark.nix
  ];

  networking.hostName          = "albert";
  programs.zsh.promptColor     = "magenta";
  virtualisation.podman.enable = true;

  system.stateVersion = "20.03";
}
