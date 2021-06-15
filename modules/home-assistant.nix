{ config, lib, options, pkgs, ... }:

{
  imports = [
    ./zwave-js-server.nix
  ];

  config.services = {
    zwave-js-server.enable = true;

    home-assistant = {
      enable = true;

      config = {
        homeassistant = {
          name        = "Home";
          unit_system = "imperial";
        };

        automation = "!include automations.yaml";

        default_config = { };
        denonavr       = { };
        homekit        = { };
        octoprint      = { };
        unifi          = { };
        zwave_js       = { };
      };

      package = (pkgs.home-assistant.override {
        # unifi, denonavr, homekit and maybe others need these modules
        extraPackages = py: with py; [ async-upnp-client aiohomekit pkgs.ffmpeg ];
      }).overrideAttrs (_: { doInstallCheck = false; });
    };

    udev.packages = [
      (pkgs.writeTextFile {
        destination = "/etc/udev/rules.d/70-zwave-dongle.rules";
        name        = "zwave-dongle-udev-rule";

        text = ''
          # Sigma Designs, Inc. Aeotec Z-Stick Gen5 (ZW090) - UZB
          SUBSYSTEM=="tty", ATTRS{idVendor}=="0658", ATTRS{idProduct}=="0200", USER="zwavejs"
        '';
      })
    ];
  };
}
