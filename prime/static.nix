{ compiler ? "ghc881" }:
let
  static-haskell-nix = fetchTarball https://github.com/nh2/static-haskell-nix/archive/d1b20f35ec7d3761e59bd323bbe0cca23b3dfc82.tar.gz;

  pkgs = (import "${static-haskell-nix}/nixpkgs.nix").pkgsMusl;

  static-haskell-nix-servay = static-haskell-nix + "/survey/default.nix";
  survey = import static-haskell-nix-servay {
    inherit compiler pkgs;
    approach = "pkgsMusl";
  };

  prime = import ./default.nix {
    inherit compiler pkgs;
    haskellPackages = survey.haskellPackages;
  };

  buildStatic = drv:
    with pkgs.haskell.lib;
    appendConfigureFlags
    (disableSharedExecutables (disableSharedLibraries drv)) [
      "--ghc-option=-optl=-static"
      "--ghc-option=-optl=-pthread"
      "--extra-lib-dirs=${pkgs.gmp6.override { withStatic = true; }}/lib"
      "--extra-lib-dirs=${pkgs.zlib.static}/lib"
      "--extra-lib-dirs=${
        pkgs.libffi.overrideAttrs (old: { dontDisableStatic = true; })
      }/lib"
    ];

in buildStatic prime.production
