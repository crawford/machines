{ pkgs, ... }:

# Note: rules that use uaccess must be ordered before 73-seat-late.rules
let
  moonlander = pkgs.writeTextFile {
    destination = "/etc/udev/rules.d/71-moonlander.rules";
    name        = "moonlander-udev-rule";

    text = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", TAG+="uaccess"
    '';
  };
in
{
  services.udev.packages = [ moonlander ];
}
