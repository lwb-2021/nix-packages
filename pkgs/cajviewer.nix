{ stdenv }:

stdenv.mkDerivation rec {
  pname = "CAJViewer";
  version = "9.0";
  src = stdenv.fetchurl {
    url = "https://download.cnki.net/cajPackage/CAJLinuxPackage/cajviewer_${version}_amd64.deb";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  nativeBuildInputs = [ stdenv.autoPatchelfHook ];
  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz
  '';

  installPhase = ''
    mkdir -p $out
  '';
}
