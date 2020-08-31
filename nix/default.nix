{ sources ? import ./sources.nix
, wasm-bindgen-version ? "0.2.67"
}:
let
  pkgs = import sources.nixpkgs {};

  gitignoreSource = (import sources."gitignore.nix" { inherit (pkgs) lib; }).gitignoreSource;

  rust-overlay = import "${sources.nixpkgs-mozilla}/rust-overlay.nix";

  rust-pkgs = rust-overlay (pkgs // rust-pkgs) pkgs;

  rust = rust-pkgs.latest.rustChannels.stable.rust.override {
    targets = [ "wasm32-unknown-unknown" ];
  };

  rustPlatform = pkgs.makeRustPlatform {
    cargo = rust;
    rustc = rust;
  };

  wasm-bindgen-src = pkgs.fetchFromGitHub {
    owner = "rustwasm";
    repo = "wasm-bindgen";
    rev = wasm-bindgen-version;
    sha256 = "0qx178aicbn59b150j5r78zya5n0yljvw4c4lhvg8x4cpfshjb5j";
  };

  wasm-bindgen-cli = rustPlatform.buildRustPackage {
    pname = "wasm-bindgen-cli";
    version = wasm-bindgen-version;

    src = wasm-bindgen-src;

    cargoBuildFlags = [ "-p wasm-bindgen-cli" ];
    cargoPatches = [ ./lock-wasm-bindgen-cli.patch ];
    cargoSha256 = "14v23sx4wrkv9p37mdzw97q5x67kfp3xw7n2wxmwbj9vzdgxvpmb";

    buildInputs = [ pkgs.pkg-config pkgs.openssl ];

    doCheck = false;
  };

  devTools = {
    inherit (pkgs)
      pre-commit
      niv nixpkgs-fmt nix-linter
      terraform-full
      ;

    inherit rust wasm-bindgen-cli;
  };

  pre-commit-check = (import sources."pre-commit-hooks.nix").run {
    src = gitignoreSource ../.;

    hooks = {
      nix-linter.enable = true;
      nixpkgs-fmt.enable = true;

      terraform-format.enable = true;

      clippy.enable = true;
      rustfmt.enable = true;

      shellcheck.enable = true;
    };

    excludes = [ "^nix/sources\\.nix$" ];
  };

in
{
  devShell = pkgs.mkShell {
    buildInputs = builtins.attrValues devTools;
    shellHook = ''
      ${pre-commit-check.shellHook}
    '';
  };

  ci = {
    inherit pre-commit-check;
  };
}
