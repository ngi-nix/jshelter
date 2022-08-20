{
  lib,
  stdenv,
  doxygen,
  freefont_ttf,
  graphviz,
  makeFontsConf,
  nodejs,
  zip,
  fetchFromGitHub,
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
  nscl = fetchFromGitHub {
    owner = "hackademix";
    repo = "nscl";
    rev = "cead3ec8eabae1638432011335cd914b91124b50";
    hash = "sha256-XdmV4at/+TQ97ToZYg/M9amkT2AlnZjEJmozVz2I1iI=";
  };
in
  stdenv.mkDerivation rec {
    pname = "jshelter";
    version = "0.11.1";

    src = fetchzip {
      url = "https://pagure.io/JShelter/webextension/archive/${version}/webextension-${version}.zip";
      hash = "sha256-QZCJmur6fHcLWKmNs1pSpXQBfXqawu+2hQUlq9uEDc4=";
    };

    nativeBuildInputs = [doxygen graphviz nodejs zip];

    # Fontconfig error: Cannot load default config file
    FONTCONFIG_FILE = makeFontsConf {
      fontDirectories = [freefont_ttf];
    };

    # we copy instead of link as sed will try to write temp files in there
    postUnpack = ''
      rm -rf source/nscl
      cp -r ${nscl} source/nscl
      chmod -R +w source/nscl
    '';

    # we get submodules and CSV using FOD
    postPatch = ''
      patchShebangs fix_manifest.sh generate_fpd.sh nscl/include.sh
      substituteInPlace Makefile \
        --replace '$(COMMON_FILES) get_csv submodules' '$(COMMON_FILES)'
    '';

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

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/jshelter
      cp -r chrome $out/share/jshelter/
      cp jshelter_firefox.zip $out/share/jshelter/

      runHook postInstall
    '';

    meta = with lib; {
      description = "An anti-malware Web browser extension to mitigate potential threats from JavaScript, including fingerprinting, tracking, and data collection";
      homepage = "https://jshelter.org";
      license = with licenses; [
        cc0
        cc-by-40
        fdl13Plus
        gpl3Plus
        mit
        mpl20
      ]; # + CC-BY-ND-4.0
      platforms = platforms.unix;
      maintainers = with maintainers; [fufexan];
    };
  }
