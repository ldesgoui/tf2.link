let pkgs = import ./nix { };
in
{
  inherit (pkgs)
    workers-source-rustfmt-check workers-modules;
}
