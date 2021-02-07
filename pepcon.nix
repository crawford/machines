{ pkgs, ... }:

{
  imports = [
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc>
    <nixos-hardware/common/pc/ssd>
    ./.
    modules/btrfs.nix
    modules/gnome.nix
    modules/rust.nix
    modules/server.nix
  ];

  boot.loader.grub = {
    device      = "/dev/sda";
    enable      = true;
    useOSProber = true;
    version     = 2;
  };

  environment = {
    shellAliases.tmux = "tmux -2";

    systemPackages = with pkgs; [
      libusb
      pkg-config
    ];
  };

  networking = {
    firewall.extraCommands = "iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE";
    hostName               = "pepcon";

    interfaces.enp7s0.ipv4.addresses = [{
      address = "192.168.0.1";
      prefixLength = 24;
    }];
  };

  programs.zsh.promptColor = "#ff8700";

  services.udev.extraRules = ''
    ATTR{idVendor}=="1366", ATTR{idProduct}=="1010", MODE="0666"
    ATTR{idVendor}=="1366", ATTR{idProduct}=="1015", MODE="0666"
    ATTR{idVendor}=="0483", ATTR{idProduct}=="374b", MODE="0666"
    ATTR{idVendor}=="21a9", ATTR{idProduct}=="1005", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="c251", ATTRS{idProduct}=="f001", MODE="0666"
  '';

  users.extraUsers.alex.extraGroups = [ "libvirtd" ];

  virtualisation = {
    podman.enable = true;

    libvirtd = {
      enable     = true;
      onShutdown = "shutdown";
    };
  };

  system.stateVersion = "20.09";
}
