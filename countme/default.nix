{ pkgs ? import <nixpkgs> { }, compiler ? "ghc881"
, haskellPackages ? pkgs.haskell.packages.${compiler} }:
let
  countme = import ./countme.nix;

  overrides = self: super: {
    countme = super.callPackage countme { llvm = pkgs.llvm; };
  };

  haskellPackages' = haskellPackages.extend overrides;
in with pkgs.haskell.lib; {
  development = disableOptimization haskellPackages'.countme;
  production = appendConfigureFlags haskellPackages'.countme [
    "--ghc-option=-Werror"
    "--ghc-option=-O2"
    "--ghc-option=-threaded"
    "--ghc-option=-rtsopts"
    "--ghc-option=-with-rtsopts=-N"
    "--ghc-option=-with-rtsopts=-A250M"
  ];
  profile = appendConfigureFlags haskellPackages'.countme [
    "--ghc-option=-O2"
    "--ghc-option=-threaded"
    "--ghc-option=-rtsopts"
    "--ghc-option=-prof"
    "--ghc-option=-fprof-auto"
    "--ghc-option=-fforce-recomp"
    "--ghc-option=-eventlog"
  ];
}
