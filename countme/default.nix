{ pkgs ? import <nixpkgs> { }, compiler ? "ghc881"
, haskellPackages ? pkgs.haskell.packages.${compiler} }:
let
  drv = import ./countme.nix;

  countme = drvs:
    pkgs.haskell.lib.overrideCabal (pkgs.haskellPackages.callPackage drv { })
    (_: { executableSystemDepends = [ pkgs.llvm ]; });

  overrides = self: super: { countme = super.callPackage countme { }; };

  haskellPackages' = haskellPackages.extend overrides;
in with pkgs.haskell.lib; {
  development = disableOptimization haskellPackages'.countme;
  production = appendConfigureFlags haskellPackages'.countme [
    "--ghc-option=-Werror"
    "--ghc-option=-O2"
    "--ghc-option=-threaded"
    "--ghc-option=-with-rtsopts=-N"
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
