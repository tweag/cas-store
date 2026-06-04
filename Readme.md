# CAS Store

Haskell library for content-addressed storage components.

This repository contains the core packages used to hash values and store cached results by content, with optional support for S3-backed hashing.

This repository moved from [https://github.com/tweag/funflow](https://github.com/tweag/funflow).

## Packages

### `cas-store`

Content-addressed storage library with local storage and remote cache support.

Key responsibilities:

- Store values by content hash
- Cache function results in a reusable content store
- Support remote cache workflows

### `cas-hashable`

Defines the `ContentHashable` API used to compute stable hashes for values and IO-backed content.

### `cas-hashable-s3`

Provides `ContentHashable` instances for S3 objects.

## Build

```bash
cabal build all
```

## Test

```bash
cabal test all
```

## Requirements

- GHC and `cabal`
- Platform-specific file notification support is enabled through package dependencies where applicable

## License

Each package in this repository is released under the MIT License. See the package-level `LICENSE` files for details.
