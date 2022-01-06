{ lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/emacs-overlay.git";
      ref = "master";
      rev = "80685d6b449905d6fa258eb4b13875327741dc02";
    }))
  ];

  environment.systemPackages = [ pkgs.ispell ];

  programs.vim.defaultEditor = lib.mkForce false;

  services.emacs = {
    enable        = true;
    defaultEditor = true;

    package = (pkgs.emacsPackagesFor (pkgs.emacsPgtkGcc.overrideAttrs (attrs: {
      postInstall = (attrs.postInstall or "") + ''
        rm $out/share/applications/emacs.desktop
      '';
    }))).emacsWithPackages (epkgs: (with epkgs; [
      nix-mode
      rust-mode
    ]));
  };
}
