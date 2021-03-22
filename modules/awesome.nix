{
  services.xserver = {
    enable                       = true;
    windowManager.awesome.enable = true;

    displayManager = {
      defaultSession = "none+awesome";
      lightdm.enable = true;
    };
  };
}
