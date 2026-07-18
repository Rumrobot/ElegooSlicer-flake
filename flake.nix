{
  description = "ElegooSlicer AppImage flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      supportedSystems = [ "x86_64" ];
      linuxSystems = map (arch: "${arch}-linux") supportedSystems;
      sources = builtins.fromJSON (builtins.readFile ./sources.json);
    in
    flake-utils.lib.eachSystem linuxSystems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.callPackage ./package.nix {
          source = sources.${system};
        };

        formatter = pkgs.nixfmt;
      }
    );
}
