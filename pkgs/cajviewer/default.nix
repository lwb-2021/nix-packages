{
  stdenv,
  fetchurl,
  fetchpatch,
  makeWrapper,
  buildFHSEnv,
  lib,

  # Dependencies
  libX11,
  freetype,
  expat,
  fontconfig,
  libxcb,
  alsa-lib,
  zlib,
  libxml2,
  libxslt,
  libGL,
  e2fsprogs,
  p11-kit,
  gmp,
  libgpg-error,
  libSM,
  libICE,
  libsForQt5,
  libtiff,

  libudev0-shim,
}:
let
  libraries = [
    stdenv.cc.cc.lib
  ];
  inner = stdenv.mkDerivation rec {
    pname = "CAJViewer";
    version = "9.0";
    src = fetchurl {
      url = "https://download.cnki.net/cajPackage/CAJLinuxPackage/cajviewer_${version}_amd64.deb";
      sha256 = "sha256-MULGM9dNzzTrrKm3ZT+IrTYZ8Lemy2iUh7bMWD7JJtM=";
    };
    nativeBuildInputs = [
      makeWrapper
    ];
    dontFixup = true;
    buildInputs = libraries;
    unpackPhase = ''
      ar x ${src}
      tar xf data.tar.xz 

    '';

    installPhase = ''
      mkdir -p $out
      mv opt $out/opt
      mv usr/share $out/share
    '';
  };

in
buildFHSEnv {
  inherit (inner) pname version;

  runScript = ''
    env QT_QPA_PLATFORM="xcb" QT_DEBUG_PLUGINS=1 ${inner}/opt/cajviewer/bin/start.sh "$@"
  '';

  targetPkgs = _: [
    libX11
    freetype
    expat
    fontconfig
    libxcb
    alsa-lib
    zlib
    libxml2
    libxslt
    libGL
    e2fsprogs
    p11-kit
    gmp
    libgpg-error
    libSM
    libICE
    libsForQt5.qt5.qtwebengine

    libudev0-shim
    (libtiff.overrideAttrs rec {
      version = "4.4.0";
      src = fetchurl {
        url = "https://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
        sha256 = "1vdbk3sc497c58kxmp02irl6nqkfm9rjs3br7g59m59qfnrj6wli";
      };
      patches = [
        ./libtiff/headers.patch
        ./libtiff/rename-version.patch
        (fetchpatch {
          name = "CVE-2022-34526.patch";
          url = "https://gitlab.com/libtiff/libtiff/-/commit/275735d0354e39c0ac1dc3c0db2120d6f31d1990.patch";
          sha256 = "sha256-faKsdJjvQwNdkAKjYm4vubvZvnULt9zz4l53zBFr67s=";
        })
        (fetchpatch {
          name = "CVE-2022-2953.patch";
          url = "https://gitlab.com/libtiff/libtiff/-/commit/48d6ece8389b01129e7d357f0985c8f938ce3da3.patch";
          sha256 = "sha256-h9hulV+dnsUt/2Rsk4C1AKdULkvweM2ypIJXYQ3BqQU=";
        })
        (fetchpatch {
          name = "CVE-2022-3626.CVE-2022-3627.CVE-2022-3597.patch";
          url = "https://gitlab.com/libtiff/libtiff/-/commit/236b7191f04c60d09ee836ae13b50f812c841047.patch";
          excludes = [ "doc/tools/tiffcrop.rst" ];
          sha256 = "sha256-L2EMmmfMM4oEYeLapO93wvNS+HlO0yXsKxijXH+Wuas=";
        })
        (fetchpatch {
          name = "CVE-2022-3598.CVE-2022-3570.patch";
          url = "https://gitlab.com/libtiff/libtiff/-/commit/cfbb883bf6ea7bedcb04177cc4e52d304522fdff.patch";
          sha256 = "sha256-SLq2+JaDEUOPZ5mY4GPB6uwhQOG5cD4qyL5o9i8CVVs=";
        })
        (fetchpatch {
          name = "CVE-2022-3970.patch";
          url = "https://gitlab.com/libtiff/libtiff/-/commit/227500897dfb07fb7d27f7aa570050e62617e3be.patch";
          sha256 = "sha256-pgItgS+UhMjoSjkDJH5y7iGFZ+yxWKqlL7BdT2mFcH0=";
        })
      ];
    })
  ];
  # shellHook = ''
  #   export
  # '';
  meta = with lib; {
    description = "A reader for CAJ, NH, KDH, CEB, PDF documents used in China Academic Journals";
    longDescription = '''';
    homepage = "";
    license = licenses.unlicense;
    platforms = platforms.linux;
  };
}
