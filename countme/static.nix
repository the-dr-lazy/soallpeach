{ compiler ? "ghc881" }:
let
  static-haskell-nix = fetchTarball
    "https://github.com/nh2/static-haskell-nix/archive/d1b20f35ec7d3761e59bd323bbe0cca23b3dfc82.tar.gz";

  nixpkgs = fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/0c960262d159d3a884dadc3d4e4b131557dad116.tar.gz";

  haskellOverlay = self: super: {
    haskell = super.haskell // {
      packages = super.haskell.packages // {
        "${compiler}" = super.haskell.packages.${compiler}.override (old: {
          overrides = super.lib.composeExtensions (old.overrides or (_: _: { }))
            (hself: hsuper: {
              semirings = super.haskell.lib.doJailbreak hself.semirings_0_5_2;
            });
        });
      };
    };
  };

  pkgs = (import nixpkgs { overlays = [ haskellOverlay ]; }).pkgsMusl;

  static-haskell-nix-servay = static-haskell-nix + "/survey/default.nix";
  survey = import static-haskell-nix-servay {
    inherit compiler pkgs;
    approach = "pkgsMusl";
  };

  countme = import ./default.nix {
    inherit compiler pkgs;
    haskellPackages = survey.haskellPackages;
  };

  buildStatic = drv:
    with pkgs.haskell.lib;
    appendConfigureFlags
    (disableSharedExecutables (disableSharedLibraries drv)) [
      "--ghc-option=-fllvm"
      "--ghc-option=-optl=-static"
      "--ghc-option=-optl=-pthread"
      "--ghc-option=-split-objs"
      "--extra-lib-dirs=${pkgs.gmp6.override { withStatic = true; }}/lib"
      "--extra-lib-dirs=${pkgs.zlib.static}/lib"
      "--extra-lib-dirs=${
        pkgs.libffi.overrideAttrs (old: { dontDisableStatic = true; })
      }/lib"
    ];

in buildStatic countme.production
