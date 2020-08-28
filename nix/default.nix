{ sources ? import ./sources.nix
}:
let
  mozilla-overlay = import sources.nixpkgs-mozilla;

  pkgs = import sources.nixpkgs {
    overlays = [ mozilla-overlay ];
  };

  gitignoreSource = (import sources."gitignore.nix" { inherit (pkgs) lib; }).gitignoreSource;

  rust = pkgs.latest.rustChannels.stable.rust.override {
    targets = [ "wasm32-unknown-unknown" ];
  };

  devTools = {
    inherit (pkgs)
      pre-commit
      niv nixpkgs-fmt nix-linter
      terraform-full
      ;

    inherit rust;
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
