{
  services.transmission = {
    enable       = true;
    openFirewall = true;

    settings.rpc-port = 9091;
  };
}
