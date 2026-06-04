{ pkgs, supportedGhcVersions }:
let defaultCompiler = "ghc9103";
in {

  casStore = pkgs.haskell-nix.cabalProject' {
    # Put your system here in order to make `nix flake show` work.
    # You can find out the system string by running:
    # `nix eval --impure --expr 'builtins.currentSystem'`
    # evalSystem = "x86_64-linux";
    src = ../.;

    name = "cas-store";

    compiler-nix-name = pkgs.lib.mkDefault defaultCompiler;

    flake.variants = pkgs.lib.foldl' (acc: compiler-nix-name:
      acc // {
        ${compiler-nix-name} = { inherit compiler-nix-name; };
        "${compiler-nix-name}-coverage".modules = [{
          packages.cas-hashable.components.library.doCoverage = true;
          packages.cas-store.components.library.doCoverage = true;
          packages.cas-hashable-s3.components.library.doCoverage = true;
        }];

      }) { } supportedGhcVersions;

    # Tools to include in the development shell
    shell.tools = {
      cabal = "3.16.0.0";
      haskell-language-server = "2.11.0.0";
      hlint = "3.10";
      weeder = "2.10.0";
      implicit-hie = "0.1.4.0";
    };

    # Non-Haskell shell tools go here
    shell.buildInputs = let
      # Add this for editors which expect to use hls-wrapper
      hls-wrapper =
        pkgs.writeShellScriptBin "haskell-language-server-wrapper" ''
          exec haskell-language-server "$@"
        '';
    in with pkgs; [ nixfmt hls-wrapper ];
  };
}
