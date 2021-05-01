{
  services = {
    gnome3.sushi.enable = true;

    xserver = {
      enable = true;

      displayManager.gdm.enable    = true;
      desktopManager.gnome3.enable = true;
    };
  };
}
