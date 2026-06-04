# Contributing to CAS Haskell libraries

Thank you for your interest in contributing! We welcome contributions from the community.

## Reporting Issues

- Use [GitHub Issues](../../issues) to report bugs or request features.

## Setting up the build tools

### Using nix

Make sure you have [Nix](https://nixos.org/download.html) installed with flakes support enabled.

You can enter a Nix shell with all dependencies by running:

``` sh
nix develop
```

This will set up the environment with the required GHC version and all necessary libraries and tools.

#### Multiple GHC versions and configurations

The Nix setup provides dev shells for various GHC versions and configurations (test coverage enabled, profiling enabled, ...). You can enter a shell with a specific GHC version by using:

``` sh
nix develop .#ghc984
```

#### Discovering available outputs

To see all available outputs (dev shells, packages, checks, etc.), you should first update `nix/project.nix` to include `evalSystem = <YOUR_SYSTEM>;` in the `pkgs.haskell-nix.cabalProject'` call, for example:

```nix
    # ...
    cardanoCanonicalLedger = pkgs.haskell-nix.cabalProject' {
        evalSystem = "x86_64-linux";
        # ...
    };
    # ...
```

Then run:

```sh
nix flake show --allow-import-from-derivation
```

This command will display a tree structure of all available flake outputs, including:

- Development shells for different GHC versions
- Package components that can be built
- Checks and formatters

#### Using direnv (optional, but recommended)

If you have [direnv](https://direnv.net/)  and [nix-direnv](https://github.com/nix-community/nix-direnv) installed, you can set it up to automatically load the Nix environment when you enter the project directory.

1. Create a `.envrc` file in the project root with the following content:

   ```sh
   watch_file \
    nix/hix.nix
   use flake
   ```

2. Allow the `.envrc` file:

   ```sh
   direnv allow
   ```

3. Now, whenever you `cd` into the project directory, direnv will automatically load the Nix environment.

### Using cabal

In order to work with the project you need to install [GHC](https://www.haskell.org/ghc/) and [cabal](https://www.haskell.org/cabal/) tools, we suggest installing them using [GHCup](https://www.haskell.org/ghcup/) project. For working with
this project you need to have GHC>=9.6 and cabal>=3.10

To install ghcup follow the instructions on site. After installing run

```sh
ghcup tui
```

And select recommended versions of GHC an cabal.

## Building the project

To build the project in the project directory run command:

``` sh
cabal build all
```

## Testing

When implementing new test suites, make sure to add them to the 'Run tests' step in `.github/workflows/nix.yaml`.

To run tests in the project directory run command:

``` sh
cabal test all
```

## Generating documentation and setting up hoogle

To generate documentation run

``` sh
cabal haddock all
```

## How to Contribute

1. **Fork the repository** and create your branch from `master`.
1. **Clone your fork** and set up the project locally, see setting up section.
1. **Make your changes** with clear, descriptive commit messages.
1. **Open a Pull Request** describing your changes and referencing any related issues.

## AI based contributions

AI based contributions are allows. However when making an AI based contribution verify that following holds:

1. Each commit solves only a single purpose and doesn't contain unnesessary changes.
2. Each commit clearly explained.
3. Try to keep the prompt used to build changes in the commit comment.

## Code of conduct

Project follows the same code conventions as cardano project [Contributor Covenant][cc-homepage].

## License

By contributing, you agree that your contributions will be licensed under the project's license.

---

Thank you for helping improve cas-store!

[cc-homepage]: https://www.contributor-covenant.org
