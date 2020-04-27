{ mkDerivation, base, binary, bytestring, servant, servant-server
, stdenv, wai, warp
}:
mkDerivation {
  pname = "countme";
  version = "0.0.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base binary bytestring servant servant-server wai warp
  ];
  description = "Haskell count me";
  license = stdenv.lib.licenses.gpl3;
}
