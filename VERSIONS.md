# Supported Helm Versions

This file tracks the Helm versions that are built and maintained by this project.

## Latest Stable Versions

| Version | Release Date | Status | Notes |
|---------|-------------|--------|-------|
| v4.0.1  | 2025-11-25  | ✅ Active | Latest Helm v4 release |
| v4.0.0  | 2025-11-12  | ✅ Active | Helm v4.0 GA release |
| v3.19.2 | 2025-11-12  | ✅ Active | Latest Helm v3 release |
| v3.19.1 | 2025-11-12  | ✅ Active | Helm v3.19 patch release |
| v3.19.0 | 2024-09-11  | ✅ Active | Helm v3.19 feature release |

## Helm v4.x Releases

| Version | Release Date | Type | Status |
|---------|-------------|------|--------|
| v4.0.1  | 2025-11-25  | Patch | ✅ Latest |
| v4.0.0  | 2025-11-12  | Major | ✅ Active |

## Helm v3.x Releases (Recent)

| Version | Release Date | Type | Status |
|---------|-------------|------|--------|
| v3.19.2 | 2025-11-12  | Patch | ✅ Latest v3 |
| v3.19.1 | 2025-11-12  | Patch | ✅ Active |
| v3.19.0 | 2024-09-11  | Minor | ✅ Active |
| v3.18.0 | 2024-08-13  | Minor | ✅ Active |
| v3.17.0 | 2024-07-09  | Minor | ✅ Active |
| v3.16.0 | 2024-06-11  | Minor | ✅ Active |
| v3.15.0 | 2024-05-07  | Minor | ✅ Active |

## Platform Support

All versions support:
- ✅ linux/amd64
- ✅ linux/arm64

## Update Schedule

- **Daily checks**: GitHub Actions runs daily at 2 AM UTC to check for new releases
- **Automatic builds**: New stable releases are automatically built and published
- **Manual builds**: Can be triggered via GitHub Actions workflow dispatch

## Requesting a Version

If you need a specific version not listed here:

1. Open an issue with the title: "Request: Helm version X.X.X"
2. Provide the use case for this version
3. We'll prioritize and build it

## Version Deprecation Policy

- Versions older than 6 months are considered legacy but still maintained
- Security patches are applied to all maintained versions
- Pre-release versions (alpha, beta, rc) are available but not recommended for production

## Links

- [Helm Releases](https://github.com/helm/helm/releases) - Official Helm release page
- [Helm Release Calendar](https://helm.sh/calendar/release) - Upcoming releases
- [Helm Support Policy](https://helm.sh/docs/topics/version_skew/) - Official support information

---

Last updated: 2025-12-02
