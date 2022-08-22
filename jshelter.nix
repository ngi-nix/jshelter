{
  lib,
  stdenv,
  doxygen,
  freefont_ttf,
  graphviz,
  makeFontsConf,
  nodejs,
  zip,
  ipv4csv,
  ipv6csv,
  src,
  version,
}:
stdenv.mkDerivation {
  pname = "jshelter";
  inherit version src;

  nativeBuildInputs = [doxygen graphviz nodejs zip];

  # Fontconfig error: Cannot load default config file
  FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [freefont_ttf];
  };

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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/jshelter
    cp jshelter_{chrome,firefox}.zip $out/share/jshelter/

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
