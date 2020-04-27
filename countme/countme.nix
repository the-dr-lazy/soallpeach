{ mkDerivation, aeson, base, bytestring, http-types, stdenv, wai
, warp
}:
mkDerivation {
  pname = "countme";
  version = "0.0.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base bytestring http-types wai warp
  ];
  description = "Haskell count me";
  license = stdenv.lib.licenses.gpl3;
}
