{
  description = "cas-store";

  inputs.hackage = {
    url = "github:input-output-hk/hackage.nix";
    flake = false;
  };
  inputs.haskellNix = {
    url = "github:input-output-hk/haskell.nix";
    inputs.hackage.follows = "hackage";
  };
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.git-hooks = {
    url = "github:cachix/git-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, flake-utils, haskellNix, git-hooks, treefmt-nix
    , ... }:
    let
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          overlays = [
            haskellNix.overlay
          ];
          inherit system;
          inherit (haskellNix) config;
        };

        inherit (pkgs) lib;

        supportedGhcVersions =
          [ "ghc967" "ghc984" "ghc9103" "ghc9122" "ghc9141" ];

        project = import ./nix/project.nix {
          inherit pkgs supportedGhcVersions referenceCDDLDir;
        };

        inherit (project) casStore;

        flake = casStore.flake { };

        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-classic.enable = true;
          };
          tools = { };
        };

        treefmtEval =
          treefmt-nix.lib.evalModule pkgs (import ./nix/treefmt.nix project);
      in lib.recursiveUpdate flake {
        project = casStore;
        legacyPackages = { inherit casStore pkgs; };

        checks = let
          perGhcChecks = lib.listToAttrs (lib.concatMap (compiler-nix-name:
            map (checkName: {
              name = "${compiler-nix-name}:${checkName}";
              value = overridePreCheck "${compiler-nix-name}:${checkName}"
                testOverrides.${checkName};
            }) (lib.attrNames testOverrides)) supportedGhcVersions);
        in defaultChecks // perGhcChecks;

        devShells = let
          mkDevShells = p: {
            # Shell with profiling enabled
            profiling = (p.appendModule {
              modules = [{ enableLibraryProfiling = true; }];
            }).shell;
            # Default shell with pre-commit hooks
            default = p.shell.overrideAttrs (old: {
              shellHook = old.shellHook + pre-commit-check.shellHook;
            });
          };
        in mkDevShells cardanoCanonicalLedger // lib.listToAttrs (map
          (compiler-nix-name:
            let
              p = cardanoCanonicalLedger.appendModule {
                inherit compiler-nix-name;
              };
            in {
              name = compiler-nix-name;
              value = p.shell // (mkDevShells p);
            }) supportedGhcVersions);

        formatter = treefmtEval.config.build.wrapper;
      });

  # --- Flake Local Nix Configuration ----------------------------
  nixConfig = {
    extra-substituters =
      [ "https://cache.iog.io" ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = "true";
  };
}
