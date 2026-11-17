# Changelog

## 0.1.1

- Fixed Home Assistant Supervisor builds by defining the runtime base image
  directly in the Dockerfile's `FROM` instruction.
- Removed deprecated `build.yaml`; both supported architectures use the same
  pinned multi-architecture base image.

## 0.1.0

- Added an `amd64`/`aarch64` Home Assistant add-on using pinned official
  AmneziaWG 3.1 userspace components.
- Added native `.conf` input with secret-safe runtime storage and validation.
- Added split-tunnel route support and safe shutdown cleanup.
- Rejected default routes and privileged shell hooks in the first release.
