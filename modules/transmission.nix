{
  services.transmission = {
    enable       = true;
    openFirewall = true;

    settings.rpc-port = 9091;
  };

  users.users.alex.extraGroups = [ "transmission" ];
}
