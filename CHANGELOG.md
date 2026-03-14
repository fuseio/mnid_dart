## [0.2.0]
### Breaking
- `decode()` now returns `MnidResult` instead of `Map`

### Added
- `MnidResult` class for typed decode results with `network` and `address` fields
- `MnidException` for specific error types (invalid checksum, version, payload)
- GitHub Actions CI/CD pipeline
- Comprehensive test suite (40 tests, up from 11)

### Changed
- Updated all dependencies to latest versions
- Stricter analysis options with additional lint rules
- Internal codecs are now private and final

## [0.1.5]
- Updated dependencies

## [0.1.4]
- Updated dependencies

## [0.1.3]
- Documentation and dependencies upgrade

## [0.1.2]
- Removed redundant dependencies

## [0.1.1]
- Added LICENSE

## [0.1.0]
- Initial release
