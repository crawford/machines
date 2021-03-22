{ pkgs, ... }:

{
  system.activationScripts.lib64 = ''
    mkdir --parents /lib64
    ln --no-target-directory --force --symbolic ${pkgs.stdenv.glibc}/lib/ld-linux-x86-64.so.2 /lib64/.ld-linux-x86-64.so.2
    mv --no-target-directory --force /lib64/.ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
  '';
}
