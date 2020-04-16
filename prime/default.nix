{ pkgs ? import <nixpkgs> { }
, compiler ? "ghc881"
, haskellPackages ? pkgs.haskell.packages.${compiler} }:
let
  prime = { mkDerivation, attoparsec, base, bzip2, conduit, conduit-algorithms
    , conduit-extra, lzma, stdenv, text, vector, bytestring, arithmoi, llvm }:
    mkDerivation {
      pname = "prime";
      version = "0.1.0.0";
      src = ./.;
      isLibrary = false;
      isExecutable = true;
      executableHaskellDepends = [ attoparsec base bytestring arithmoi ];
      executableSystemDepends = [ llvm ];
      description = "Haskell primality test algorithm for soallpeach";
      license = stdenv.lib.licenses.gpl3;
    };

  overrides = self: super: {
    prime = super.callPackage prime { llvm = pkgs.llvm; };
  };

  haskellPackages' = haskellPackages.extend overrides;
in with pkgs.haskell.lib; {
  development = appendConfigureFlags (disableOptimization haskellPackages'.prime) [
    "--ghc-option=-threaded"
    "--ghc-option=-rtsopts"
  ];
  production = appendConfigureFlags haskellPackages'.prime [
    "--ghc-option=-Werror"
    "--ghc-option=-O2"
    "--ghc-option=-threaded"
    "--ghc-option=-rtsopts"
    "--ghc-option=-with-rtsopts=-N"
  ];
}
