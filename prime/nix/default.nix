args:
let pkgs = import <nixpkgs> args;
in (if builtins.currentSystem == "x86_64-linux" then pkgs.pkgsMusl else pkgs)
