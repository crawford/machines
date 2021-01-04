{ pkgs, ... }:

{
  programs.wireshark = {
    enable  = true;
    package = pkgs.wireshark-qt;
  };

  users.users.alex.extraGroups = [ "wireshark" ];
}
