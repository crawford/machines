{ pkgs, ... }:

{
  imports = [
    ./zsh.nix
  ];

  nix = {
    gc = {
      automatic = true;
      options   = "--delete-older-than 30d";
    };

    settings = {
      allowed-users       = [ "alex" ];
      auto-optimise-store = true;
    };
  };

  boot = {
    cleanTmpDir    = true;
    loader.timeout = 1;
  };

  environment = {
    homeBinInPath = true;

    shellAliases = {
      ush = "ssh -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null";
      ucp = "scp -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null";
      utc = "TZ=UTC date";
    };
  };

  programs = {
    command-not-found.enable = true;
    iftop.enable             = true;
    iotop.enable             = true;
    mtr.enable               = true;
  };

  security.sudo.wheelNeedsPassword = false;

  services = {
    sshguard.enable    = true;
    xserver.xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";

    openssh = {
      enable                 = true;
      openFirewall           = true;
      passwordAuthentication = false;
      permitRootLogin        = "no";
    };
  };

  time.timeZone = pkgs.lib.mkOverride 1100 "US/Pacific";

  users = {
    defaultUserShell = "${pkgs.zsh}/bin/zsh";

    users.alex = {
      isNormalUser = true;
      extraGroups  = [ "wheel" ];
    };
  };
}
