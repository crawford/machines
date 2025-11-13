{ lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ispell ];
  programs.vim.defaultEditor = lib.mkForce false;

  # nix-mode uses `nix show-derivation`
  nix.settings.experimental-features = [ "nix-command" ];

  home-manager.users.alex = { pkgs, ... }: {
    programs.emacs = {
      enable      = true;
      extraConfig = lib.readFile ./init.el;

      extraPackages = epkgs: with epkgs; [
        ace-window
        cider
        company
        eglot
        hungry-delete
        magit
        nov
        org
        vterm

        clojure-mode
        go-mode
        json-mode
        markdown-mode
        nix-mode
        org-roam
        protobuf-mode
        rust-mode
        swift-mode
        yaml-mode
      ];
    };
  };
}
