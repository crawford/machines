{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x250>
    modules/btrfs.nix
    modules/common.nix
    modules/gnome.nix
    modules/laptop.nix
    modules/rust.nix
    modules/udev.nix
    modules/wireshark.nix
  ];

  networking.hostName      = "deepwater";
  programs.zsh.promptColor = "blue";

  services.avahi = {
    enable  = true;
    nssmdns = true;
  };

  virtualisation = {
    podman.enable = true;

    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
    };
  };
}
