let
  config = {
    packageOverrides = pkgs: rec {
      haskellPackages = pkgs.haskell.packages.ghc883.override {
        overrides = self: super: {
          prime = super.callCabal2nix "prime" ./. {};
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };

  prime =  pkgs.haskellPackages.prime;
in
with pkgs.haskell.lib; {
  development = disableOptimization prime;
  production  = failOnAllWarnings (appendConfigureFlag prime "--ghc-options=-O2");
}
