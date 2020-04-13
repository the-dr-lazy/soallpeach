{ system ? builtins.currentSystem }:
let
  config = {
    packageOverrides = pkgs: {
      haskellPackages = pkgs.haskell.packages.ghc883.override {
        overrides = self: super: {
          prime = super.callCabal2nix "prime" ./. {};
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; inherit system; };

  prime = pkgs.haskellPackages.prime;
in
with pkgs.haskell.lib; {
  development = disableOptimization prime;
  production  = failOnAllWarnings (appendConfigureFlag prime "--ghc-options=-O2");
}
