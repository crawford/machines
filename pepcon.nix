{ pkgs, ... }:

{
  imports = [
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc>
    <nixos-hardware/common/pc/ssd>
    modules/alacritty.nix
    modules/btrfs.nix
    modules/common.nix
    modules/ddcci.nix
    modules/emacs.nix
    modules/gnome.nix
    modules/rust.nix
    modules/server.nix
    modules/udev.nix
  ];

  boot.loader.grub = {
    device      = "/dev/sda";
    enable      = true;
    useOSProber = true;
    version     = 2;
  };

  console.keyMap = "us";

  environment = {
    shellAliases.tmux = "tmux -2";

    systemPackages = with pkgs; [
      libusb
      pkg-config
    ];
  };

  networking = {
    hostName = "pepcon";

    interfaces.enp7s0.useDHCP = true;
  };

  programs.zsh.promptColor = "#ff8700";

  services.udev.extraRules = ''
    ATTR{idVendor}=="1366", ATTR{idProduct}=="1010", MODE="0666"
    ATTR{idVendor}=="1366", ATTR{idProduct}=="1015", MODE="0666"
    ATTR{idVendor}=="0483", ATTR{idProduct}=="374b", MODE="0666"
    ATTR{idVendor}=="21a9", ATTR{idProduct}=="1005", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="c251", ATTRS{idProduct}=="f001", MODE="0666"
  '';

  systemd.services.crawfice-lights = {
    description = "Turns on and off the lights";
    wantedBy = [ "sleep.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      User = "alex";
      EnvironmentFile = "/home/alex/.config/crawfice-lights/env";
      ExecStart = "${pkgs.home-assistant-cli}/bin/hass-cli state turn_off light.crawfice";
      ExecStop = [
        "/bin/sh -c 'SERVER=$(basename $HASS_SERVER); while ! ${pkgs.iputils}/bin/ping -c 1 $SERVER > /dev/null 2>&1; do sleep 0.5; done'"
        "${pkgs.home-assistant-cli}/bin/hass-cli state turn_on light.crawfice"
      ];
    };

    unitConfig = {
      Before = [ "sleep.target" ];
      StopWhenUnneeded = "yes";
    };
  };

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
