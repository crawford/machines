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
        octoprint      = { };
        unifi          = { };
        zwave_js       = { };
      };

      package = (pkgs.home-assistant.override {
        # unifi, denonavr, and maybe others need this module
        extraPackages = py: with py; [ async-upnp-client ];
      }).overrideAttrs (_: { doInstallCheck = false; });
    };
  };
}
