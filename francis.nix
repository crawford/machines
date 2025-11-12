{ config, lib, pkgs, ... }:

{
  imports = [
    modules/emacs.nix
    modules/rdp.nix
    modules/udev.nix
    <home-manager/nixos>
  ];

  nixpkgs.config = {
    allowUnfree = true;

    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "1password"
      "slack"
    ];
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable      = true;
  };

  # Copied from https://www.reddit.com/r/NixOS/comments/r0mfo8/comment/jtu0ne3/
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome-text-editor
    # cheese # webcam tool
    gnome-music
    gnome-terminal
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    # totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    # gnome-calculator
    yelp # help viewer
    # gnome-maps
    gnome-weather
    # gnome-contacts
    simple-scan
  ];

  hardware = {
    coral.pcie.enable   = true;
    saleae-logic.enable = true;
  };

  home-manager.users.alex = { pkgs, ... }: {
    home.stateVersion = "24.11";
  };

  networking = {
    firewall.enable = false;
    hostName        = "francis";
  };

  programs = {
    mtr.enable       = true;
    wireshark.enable = true;
  };

  services = {
    openssh.enable = true;

    xserver = {
      enable = true;

      desktopManager.gnome.enable = true;
      displayManager.gdm.enable   = true;
    };
  };

  time.timeZone = "US/Pacific";

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" "wireshark" ];
    packages = with pkgs; [
      _1password-gui
      bind
      fd
      firefox
      freecad
      gimp
      git
      git-lfs
      htop
      ripgrep
      saleae-logic-2
      slack
      super-slicer
      tree

      cljfmt
      clojure
      clojure-lsp
      leiningen
    ];
  };

  virtualisation.docker = {
    enable = true;

    autoPrune.enable = true;
    rootless.enable  = true;
  };
}
