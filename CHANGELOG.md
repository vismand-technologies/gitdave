# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [0.1.0-beta.1] - 2025-08-15

### Added
- Initial public beta of GitDave (Electron + React + TypeScript)
- Multi-arch packaging:
  - Windows: NSIS (.exe) and MSI (.msi), x64 and arm64
  - macOS: DMG for x64 and arm64, hardened runtime and notarization hooks
  - Linux: .deb and AppImage, x64 and arm64
- CI/CD:
  - GitHub Actions for tagged releases and nightly prereleases
  - Windows WiX setup in CI for MSI builds
- Code signing scaffolding:
  - Windows: env-based certificate configuration
  - macOS: entitlements and notarization env placeholders
- Icons configuration for all platforms

### Notes
- Unsigned builds may show OS warnings until code signing secrets are configured in CI.
- Nightly builds can be triggered manually from GitHub Actions if needed.
