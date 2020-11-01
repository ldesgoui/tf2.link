let pkgs = import ./nix { };
in
pkgs.mkShell {
  buildInputs = builtins.attrValues {
    inherit (pkgs)
      niv nixpkgs-fmt nix-linter
      wasm-bindgen-cli
      ;

    rust = pkgs.rustChannels.stable.rust.override {
      targets = [ "wasm32-unknown-unknown" ];
    };
  };
}
