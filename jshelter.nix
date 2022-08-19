{
  lib,
  stdenv,
  doxygen,
  fetchurl,
  fetchzip,
}: let
  ipv4csv = fetchurl {
    url = "https://www.iana.org/assignments/locally-served-dns-zones/ipv4.csv";
    hash = "sha256-NYsxbG0WecF0+BO7hFlgmAACtDfL8P5PB556Z8iarms=";
  };
  ipv6csv = fetchurl {
    url = "https://www.iana.org/assignments/locally-served-dns-zones/ipv6.csv";
    hash = "sha256-9ImunHzGKDZACTknDe86EwUHZv2DS1g9U+ofDC3Pa20=";
  };
in
  stdenv.mkDerivation rec {
    pname = "jshelter";
    version = "0.11.1";

    src = fetchzip {
      url = "https://pagure.io/JShelter/webextension/archive/${version}/webextension-${version}.zip";
      hash = "sha256-QZCJmur6fHcLWKmNs1pSpXQBfXqawu+2hQUlq9uEDc4=";
    };

    nativeBuildInputs = [doxygen];

    preBuild = ''
      cp ${ipv4csv} common/ipv4.dat
      cp ${ipv6csv} common/ipv6.dat
    '';

    # override wget fetching
    buildPhase = ''
      runHook preBuild

      make firefox chrome clean docs

      runHook postBuild
    '';

    meta = with lib; {
      description = "An anti-malware Web browser extension to mitigate potential threats from JavaScript, including fingerprinting, tracking, and data collection";
      homepage = "https://jshelter.org";
      license = licenses.gpl3Plus;
      platforms = platforms.unix;
      maintainers = with maintainers; [fufexan];
    };
  }
