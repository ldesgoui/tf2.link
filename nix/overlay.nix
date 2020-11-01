self: pkgs: {
  wasm-bindgen-cli = self.callPackage ./wasm-bindgen-cli.nix { };

  workers-source = pkgs.lib.cleanSourceWith {
    name = "workers-source";
    src =
      pkgs.lib.sourceByRegex
        (pkgs.gitignoreSource ../.)
        [
          ''^Cargo\.(toml|lock)$''
          ''^(worker-version)(/Cargo\.toml|/src|/src/.*)?$''
        ];
  };

  workers-source-rustfmt-check = pkgs.stdenv.mkDerivation {
    name = "${self.workers-source.name}-rustfmt-check";

    src = self.workers-source;
    nativeBuildInputs = [
      pkgs.rustChannels.stable.cargo
      (pkgs.rustChannels.stable.rust.override { extensions = [ "clippy-preview" ]; })
    ];

    buildCommand = ''
      cd $src
      cargo fmt -- --check
      touch $out
    '';
  };

  workers-modules = pkgs.naersk.buildPackage {
    name = "worker-modules";
    root = self.workers-source;

    targets = [ "worker-version" ];

    cargoBuildOptions = old: old ++ [ "--target wasm32-unknown-unknown" ];
    copyBins = false;
    copyLibs = true;
  };



}
