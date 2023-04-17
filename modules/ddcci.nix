{ config, pkgs, ... }:

{
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    kernelModules       = [ "ddcci" "i2c-dev" ];
  };

  services.udev.packages = let
    rule = pkgs.writeTextFile {
      destination = "/etc/udev/rules.d/99-ddcci.rules";
      name        = "ddcci-hotplug";

      text = ''
        SUBSYSTEM=="i2c", ACTION=="add", ATTR{name}=="Radeon i2c bit bus 0x93" \
        , TAG+="ddcci", TAG+="systemd" \
        , ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
      '';
    };
  in
    [ rule ];

  systemd.services."ddcci@" = {
    description = "ddcci handler";

    after              = [ "graphical.target" ];
    scriptArgs         = "%i";
    serviceConfig.Type = "oneshot";

    script = ''
      INSTANCE=$1
      BUS=$(echo ''${INSTANCE} | cut -d "-" -f 2)

      echo "Trying to attach ddcci to ''${INSTANCE}"
      i=0
      while ((i++ < 5))
      do
        if ${pkgs.ddcutil}/bin/ddcutil getvcp 10 -b ''${BUS}
        then
          echo ddcci 0x37 > "/sys/bus/i2c/devices/''${INSTANCE}/new_device"
          echo "ddcci attached to ''${INSTANCE}"
          exit 0
        else
          sleep 5
        fi
      done

      exit 1
    '';
  };
}
