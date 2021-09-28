{
  description = "Cloud Haskell: Erlang-style concurrency in Haskell";
  inputs = {
    np.url = "github:nixos/nixpkgs/haskell-updates";
    fu.url = "github:numtide/flake-utils/master";
  };
  outputs = { self, np, fu }:
    with fu.lib;
    with np.lib;
    eachSystem [ "x86_64-linux" ] (system:
      let
        version =
          "${substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";
        mkOverlay = { package }:
          self: _:
          with self;
          with haskell.lib;
          with haskellPackages.extend (self: _: with self; rec { }); {
            "${package}" =
              overrideCabal (doJailbreak (callCabal2nix "${package}" ./. { }))
              (o: { version = "${o.version}.${version}"; });
          };
        overlays = [ (mkOverlay { package = "distributed-process"; }) ];
        config = { };
      in with (import np { inherit system overlays config; }); rec {
        packages =
          flattenTree (recurseIntoAttrs { inherit distributed-process; });
        defaultPackage = packages.distributed-process;
        overlay = mkOverlay { package = "distributed-process"; };
      });
}
