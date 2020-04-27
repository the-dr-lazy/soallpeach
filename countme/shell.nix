{ pkgs ? import <nixpkgs> { }, countme ? import ./. { } }:

with pkgs;
mkShell { inputFrom = [ countme.development.env ]; }
