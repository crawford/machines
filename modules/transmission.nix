{
  services.transmission = {
    enable       = true;
    openFirewall = true;
    port         = 9091;
  };

  users.users.alex.extraGroups = [ "transmission" ];
}
