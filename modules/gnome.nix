{
  services = {
    gnome.sushi.enable = true;

    xserver = {
      enable = true;

      displayManager.gdm.enable    = true;
      desktopManager.gnome.enable = true;
    };
  };
}
