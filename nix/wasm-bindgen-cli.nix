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
  cargoSha256 = "0dc47381d7j3i555wkj8dzszbhk99mhr9pgg4gf8f2nq0vp19y5a";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  doCheck = false;
}
