# Home Assistant AmneziaWG Client

Home Assistant add-on repository containing a userspace AmneziaWG client.
The add-on is based on the official `amneziawg-go` and `amneziawg-tools`
projects and does not require an AmneziaWG kernel module on Home Assistant OS.

See [the add-on documentation](amnezia_client/DOCS.md) for installation,
configuration, security notes, and current routing limitations.

The repository is ready to be published as a standalone Git repository. For
local development, copy or link `amnezia_client/` into Home Assistant's local
add-ons directory and reload the add-on store.

CI runs the Home Assistant add-on linter, Hadolint, ShellCheck, configuration
tests, and test builds for both supported architectures.
