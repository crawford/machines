{ lib, pkgs, ... }:

{
  # environment.systemPackages = [ pkgs.ispell ];
  # programs.vim.defaultEditor = lib.mkForce false;

 # home-manager.users.alex = { pkgs, ... }: {
    programs.emacs = {
      enable      = true;
      extraConfig = lib.readFile ./init.el;

      extraPackages = epkgs: with epkgs; [
        ace-window
        company
        eglot
        hungry-delete
        magit
        nov
        org
        symon
        tree-sitter-indent
        # tree-sitter-langs
        vterm

        go-mode
        json-mode
        markdown-mode
        nix-mode
        org-roam
        protobuf-mode
        rust-mode
        typescript-mode
        yaml-mode
      ];

      overrides = self: super: rec {
        # Taken from https://github.com/magit/magit/issues/5011#issuecomment-1838598138
        seq = self.callPackage ({ elpaBuild, fetchurl, lib }:
          elpaBuild rec {
            pname = "seq";
            ename = "seq";
            version = "2.24";
            src = fetchurl {
              url = "https://elpa.gnu.org/packages/seq-2.24.tar";
              sha256 = "1w2cysad3qwnzdabhq9xipbslsjm528fcxkwnslhlkh8v07karml";
            };
            packageRequires = [];
            meta = {
              homepage = "https://elpa.gnu.org/packages/seq.html";
              license = lib.licenses.free;
            };
            # tests take a _long_ time to byte-compile, skip them
            postInstall = ''rm -r $out/share/emacs/site-lisp/elpa/${pname}-${version}/tests'';
          }) {};
      };
    };
  #};
}
