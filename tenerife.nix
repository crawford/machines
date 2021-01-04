{ config, lib, pkgs, ... }:

let cfg = config.tenerife;
in
{
  imports = [
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc>
    <nixos-hardware/common/pc/hdd>
    ./.
    modules/btrfs.nix
    modules/matrix.nix
    modules/server.nix
  ];

  options.tenerife = {
    domain = lib.mkOption {
      description = ''
        The domain of the site.
      '';
    };

    gateway = lib.mkOption {
      description = ''
        The IP address of the gateway.
      '';
    };

    ipAddress = lib.mkOption {
      description = ''
        The IP address of the machine.
      '';
    };

    ipAddressPrefix = lib.mkOption {
      description = ''
        The CIDR prefix length of address of the machine.
      '';
      type = lib.types.ints.between 0 32;
    };

    nameservers = lib.mkOption {
      description = ''
        The list of nameservers to use.
      '';
    };
  };

  config = {
    boot.loader = {
     efi.canTouchEfiVariables = true;
     systemd-boot.enable      = true;
    };

    networking = {
      domain      = cfg.domain;
      hostName    = "tenerife";
      nameservers = cfg.nameservers;
      useDHCP     = false;

      defaultGateway = {
        address   = cfg.gateway;
        interface = "eno1";
      };

      interfaces.eno1.ipv4.addresses = [{
        address      = cfg.ipAddress;
        prefixLength = cfg.ipAddressPrefix;
      }];
    };

    programs.zsh.promptColor = "yellow";

    services.nginx.virtualHosts."${config.networking.domain}".locations = {
      "/".return = "301 https://www.${config.networking.domain}$request_uri";
    };

    system = {
      stateVersion = "20.03";

      autoUpgrade = {
        allowReboot = true;
        enable      = true;
      };
    };
  };
}
