{ pkgs ? import <nixpkgs> { }, compiler ? "ghc881"
, haskellPackages ? pkgs.haskell.packages.${compiler} }:
let
  prime = { mkDerivation, attoparsec, base, bzip2, conduit, conduit-algorithms
    , conduit-extra, lzma, stdenv, text, vector }:
    mkDerivation {
      pname = "prime";
      version = "0.1.0.0";
      src = ./.;
      isLibrary = false;
      isExecutable = true;
      executableHaskellDepends = [
        attoparsec
        base
        conduit
        conduit-algorithms
        conduit-extra
        text
        vector
      ];
      executableSystemDepends = [ bzip2 lzma ];
      description = "Haskell primality test algorithm for soallpeach";
      license = stdenv.lib.licenses.gpl3;
    };

  overrides = self: super: { prime = super.callPackage prime {}; };

  haskellPackages' = haskellPackages.extend overrides;
in with pkgs.haskell.lib; {
  development = disableOptimization haskellPackages'.prime;
  production = appendConfigureFlags haskellPackages'.prime [
    "--ghc-option=-Werror"
    "--ghc-option=-O3"
    "--ghc-option=-threaded"
    "--ghc-option=-rtsopts"
    "--ghc-option=-with-rtsopts=-N"
  ];
}
