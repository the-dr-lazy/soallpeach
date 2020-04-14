{ pkgs ? import <nixpkgs> {}, prime ? import ./. {} }:

with pkgs;
mkShell {
  inputFrom = [
    prime.development.env
  ];
}
