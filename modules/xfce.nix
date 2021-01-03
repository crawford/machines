{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs.xfce; [
    xfce4-whiskermenu-plugin
    xfce4-xkb-plugin
    xfce4-battery-plugin
    xfce4-cpugraph-plugin
    xfce4-netload-plugin
    xfce4-sensors-plugin
  ];

  services.xserver = {
    enable = true;

    desktopManager.xfce.enable = true;
  };
}
