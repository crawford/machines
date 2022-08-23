{ lib, pkgs, ... }:

{
  # nixpkgs.overlays = [
  #   (import (builtins.fetchGit {
  #     url = "https://github.com/nix-community/emacs-overlay.git";
  #     ref = "master";
  #     rev = "80685d6b449905d6fa258eb4b13875327741dc02";
  #   }))
  # ];
  # nixpkgs.config = {
    # packageOverrides = pkgs: {
      # unstable = import <nixos-unstable> { };
    # };
  # };

  environment = {
    shellAliases.e = "emacsclient --tty";
    systemPackages = with pkgs; [ ispell rust-analyzer ripgrep fd ];
  };

  programs.vim.defaultEditor = lib.mkForce false;

  services.emacs = {
    enable        = true;
    defaultEditor = true;

    # package = (pkgs.emacsPackagesFor (pkgs.emacsPgtkGcc.overrideAttrs (attrs: {
    # package = (pkgs.unstable.emacsPackagesFor (pkgs.unstable.emacs.overrideAttrs (attrs: {
    package = (pkgs.emacsPackagesFor (pkgs.emacs.overrideAttrs (attrs: {
      postInstall = (attrs.postInstall or "") + ''
        rm $out/share/applications/emacs.desktop
      '';

      propagatedBuildInputs = with pkgs; [
        ispell
        rust-analyzer
        ripgrep
        fd
      ];
    }))).emacsWithPackages (epkgs: (with epkgs; [
      # company
      eglot
      # flycheck
      # flycheck-rust
      ivy
      magit
      nix-mode
      # projectile
      rust-mode
      # rustic
      # lsp-mode
      # lsp-ui
    ]));
  };
}
