{ pkgs ? import <nixpkgs> { }
, compiler ? "ghc881"
, haskellPackages ? pkgs.haskell.packages.${compiler} }:
let
  prime =
    { mkDerivation, arithmoi, base, bytestring, stdenv, vector, llvm }:
    mkDerivation {
      pname = "prime";
      version = "0.1.0.0";
      src = ./.;
      isLibrary = false;
      isExecutable = true;
      executableHaskellDepends = [ base bytestring arithmoi vector ];
      executableSystemDepends = [ llvm ];
      description = "Haskell primality test algorithm for soallpeach";
      license = stdenv.lib.licenses.gpl3;
    };

  overrides = self: super: {
    prime = super.callPackage prime { llvm = pkgs.llvm; };
  };

  haskellPackages' = haskellPackages.extend overrides;
in with pkgs.haskell.lib; {
  development = disableOptimization haskellPackages'.prime;
  production = appendConfigureFlags haskellPackages'.prime [
    "--ghc-option=-Werror"
    "--ghc-option=-O2"
    "--ghc-option=-threaded"
    "--ghc-option=-rtsopts"
    "--ghc-option=-with-rtsopts=-N"
  ];
  profile = appendConfigureFlags haskellPackages'.prime [
    "--ghc-option=-O2"
    "--ghc-option=-threaded"
    "--ghc-option=-rtsopts"
    "--ghc-option=-with-rtsopts=-N"
    "--ghc-option=-prof"
    "--ghc-option=-fprof-auto"
    "--ghc-option=-fforce-recomp"
    "--ghc-option=-eventlog"
  ];
}
