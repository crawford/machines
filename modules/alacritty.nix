{ pkgs, ... }:

{
  users.users.alex.packages = [ pkgs.alacritty ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      alacritty = pkgs.symlinkJoin {
        name = "alacritty";
        paths = [ pkgs.alacritty ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/alacritty --set XCURSOR_THEME Adwaita
        '';
      };
    };
  };
}
