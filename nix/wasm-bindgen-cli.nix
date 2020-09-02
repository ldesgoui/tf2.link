{ rustPlatform, fetchFromGitHub, pkg-config, openssl }:

let
  version = "0.2.67";
in

rustPlatform.buildRustPackage {
  pname = "wasm-bindgen-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "rustwasm";
    repo = "wasm-bindgen";
    rev = version;
    sha256 = "0qx178aicbn59b150j5r78zya5n0yljvw4c4lhvg8x4cpfshjb5j";
  };

  cargoBuildFlags = [ "-p wasm-bindgen-cli" ];
  cargoPatches = [ ./wasm-bindgen-cargo-lock.patch ];
  cargoSha256 = "14v23sx4wrkv9p37mdzw97q5x67kfp3xw7n2wxmwbj9vzdgxvpmb";

  buildInputs = [ pkg-config openssl ];

  doCheck = false;
}
