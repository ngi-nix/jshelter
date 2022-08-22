{
  description = "An anti-malware Web browser extension to mitigate potential threats from JavaScript, including fingerprinting, tracking, and data collection!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jshelter = {
      url = "https://pagure.io/JShelter/webextension.git";
      type = "git";
      submodules = true;
      flake = false;
    };
    ipv4csv = {
      url = "https://www.iana.org/assignments/locally-served-dns-zones/ipv4.csv";
      flake = false;
    };
    ipv6csv = {
      url = "https://www.iana.org/assignments/locally-served-dns-zones/ipv6.csv";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    jshelter,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux"];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgsFor = genSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      });
    mkDate = longDate: (nixpkgs.lib.concatStringsSep "-" [
      (__substring 0 4 longDate)
      (__substring 4 2 longDate)
      (__substring 6 2 longDate)
    ]);
  in {
    overlays.default = final: prev: {
      jshelter = prev.callPackage ./jshelter.nix {
        version = mkDate (jshelter.lastModifiedDate or "19700101") + "_" + jshelter.shortRev;
        src = jshelter;
        inherit (inputs) ipv4csv ipv6csv;
      };
    };

    packages = genSystems (system: rec {
      inherit (pkgsFor.${system}) jshelter;
      default = jshelter;
    });
  };
}
