{ sources ? import ./sources.nix
}:

let
  pkgs = import sources.nixpkgs {
    overlays = [
      (import "${sources.nixpkgs-mozilla}/rust-overlay.nix")
      (import ./overlay.nix)
    ];
  };

  inherit (import sources."gitignore.nix" { inherit (pkgs) lib; }) gitignoreSource;

  rust = pkgs.latest.rustChannels.stable.rust.override {
    targets = [ "wasm32-unknown-unknown" ];
  };

  naersk = pkgs.callPackage sources.naersk {
    cargo = pkgs.latest.rustChannels.nightly.cargo;
    rustc = rust;
  };

  src = gitignoreSource ../.;

  wasm-modules = naersk.buildPackage {
    root = src;

    targets = [ "wasm-test" ];

    cargoBuildOptions = old: old ++ [ "--target wasm32-unknown-unknown" ];
    copyLibs = true;
  };

in
{
  inherit wasm-modules;

  devShell = pkgs.mkShell {
    buildInputs = builtins.attrValues {
      inherit (pkgs)
        niv nixpkgs-fmt nix-linter
        wasm-bindgen-cli
        terraform-full
        ;

      inherit
        rust
        ;
    };
  };

  ci = {
    inherit
      wasm-modules
      ;
  };
}
