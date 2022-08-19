{
  description = "An anti-malware Web browser extension to mitigate potential threats from JavaScript, including fingerprinting, tracking, and data collection!";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux"];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgsFor = nixpkgs.legacyPackages;
  in {
    overlays.default = final: prev: {
      jshelter = prev.callPackage ./jshelter.nix {};
    };

    packages = genSystems (system: rec {
      inherit (self.overlays.default null pkgsFor.${system}) jshelter;
      default = jshelter;
    });
  };
}
