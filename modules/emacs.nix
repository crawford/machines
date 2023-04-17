{ lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ispell ];

  programs.vim.defaultEditor = lib.mkForce false;

  services.emacs = {
    enable        = true;
    defaultEditor = true;

    package = (pkgs.emacs.overrideAttrs (self: {
      postInstall = (self.postInstall or "") + ''
        rm $out/share/applications/emacs.desktop
      '';
    })).pkgs.withPackages (epkgs: (with epkgs; [
      eglot
      ivy
      magit
      markdown-mode
      nov
      nix-mode
      org
      org-roam
      rust-mode
      vterm
    ]));
  };
}
