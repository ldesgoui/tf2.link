{ sources ? import ./sources.nix
}:
let
  pkgs = import sources.nixpkgs {
    overlays = [
      (import "${sources.nixpkgs-mozilla}/rust-overlay.nix")
      sources-overlay
      (import ./overlay.nix)
    ];
  };

  sources-overlay = self: pkgs: {
    rustChannels =
      let
        f = manifest:
          pkgs.lib.rustLib.fromManifestFile
            manifest
            { inherit (pkgs) stdenv fetchurl patchelf; };
      in
      {
        stable = f sources.rust-stable-manifest;
        nightly = f sources.rust-nightly-manifest;
      };

    inherit (import sources."gitignore" { inherit (pkgs) lib; }) gitignoreSource;


    naersk = pkgs.callPackage sources.naersk {
      cargo = self.rustChannels.nightly.cargo;
      rustc = self.rustChannels.stable.rust.override { targets = [ "wasm32-unknown-unknown" ]; };
    };
  };
in
pkgs
