# 1.1.2

- Underlying `hashable` library changed a way how hash is calculated in for the newtypes, so hashes in the previous version
  no longer work. It may require migration in the tools, but update to this version should be explicit.

# 1.0.2

- Fix space leak when hashing structure where instances were derived using `Generic`. Now hashing happen in constant space. @guibou.
