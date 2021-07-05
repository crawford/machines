{ pkgs, ... }:

# Note: rules that use uaccess must be ordered before 73-seat-late.rules
let
  giantGecko = pkgs.writeTextFile {
    destination = "/etc/udev/rules.d/73-giant-gecko.rules";
    name        = "giant-gecko-rule";

    text = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="1366", ATTR{idProduct}=="1015", TAG+="uaccess"
    '';
  };
  marquee = pkgs.writeTextFile {
    destination = "/etc/udev/rules.d/99-marquee.rules";
    name        = "marquee-udev-rule";

    text = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="2544", ATTR{idProduct}=="0002", TAG+="uaccess"
    '';
  };
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
  services.udev.packages = [ giantGecko marquee moonlander ];
}
