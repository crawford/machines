{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x250>
    ./.
    modules/btrfs.nix
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

  virtualisation = {
    podman.enable = true;

    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
    };
  };
}
