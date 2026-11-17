# AmneziaWG Client add-on

## Purpose and behavior

The add-on creates an `awg0` userspace AmneziaWG interface in Home Assistant's
host network namespace. Routes listed in each peer's `AllowedIPs` become
available to Home Assistant and other host-network services. It uses the
official `amneziawg-go` and `amneziawg-tools` implementations, so no matching
kernel module is required.

The initial experimental release supports `amd64` and `aarch64` Home Assistant
systems and split-tunnel routing only. It intentionally has no web UI or
public port.

## Installation

For local testing, copy the `amnezia_client` directory to `/addons/` on the
Home Assistant host, then reload **Settings > Add-ons > Add-on store** and
install **AmneziaWG Client** from **Local add-ons**.

For repository installation, publish the `ha-amnezia-client` directory as the
root of the
[`NickA2110/home-assistant-amnezia-client`](https://github.com/NickA2110/home-assistant-amnezia-client)
Git repository and add that repository URL to the Home Assistant add-on store.

## Configuration

Export the native AmneziaWG client configuration and paste its complete text
into the `configuration` option. Keep the original `[Interface]`, `[Peer]`, and
all version-specific parameters (`J*`, `S*`, `H*`, `I*`, and AmneziaWG 3.x
fields) unchanged. For example:

```yaml
configuration: |-
  [Interface]
  PrivateKey = REPLACE_WITH_THE_CLIENT_PRIVATE_KEY
  Address = 10.8.1.2/32
  DNS = 1.1.1.1
  MTU = 1280
  Jc = 4
  Jmin = 10
  Jmax = 50
  S1 = 98
  S2 = 52
  H1 = 123456789
  H2 = 123456790
  H3 = 123456791
  H4 = 123456792

  [Peer]
  PublicKey = REPLACE_WITH_THE_SERVER_PUBLIC_KEY
  PresharedKey = REPLACE_IF_PRESENT
  Endpoint = vpn.example.com:51820
  AllowedIPs = 10.8.1.0/24
  PersistentKeepalive = 25
```

The add-on writes this value to `/etc/amnezia/amneziawg/awg0.conf` inside its
ephemeral container with mode `0600`. It never logs the configuration. Home
Assistant Supervisor still stores add-on options persistently, so treat its
backups and configuration access as secret-bearing data. Never commit a real
private key or paste it into issue reports.

The required secrets are the client `PrivateKey` and, when the server uses it,
`PresharedKey`. Obtain them from the client profile exported by the same
Amnezia server; do not generate replacement obfuscation or peer values by
hand. The add-on will not start while the private key or required peer fields
are empty.

## Limitations and safety

- `AllowedIPs = 0.0.0.0/0` and `AllowedIPs = ::/0` are rejected. A default
  route could redirect Supervisor and Home Assistant management traffic and
  make the appliance unreachable. List only the remote networks that must use
  the tunnel.
- `PreUp`, `PostUp`, `PreDown`, and `PostDown` are rejected because they execute
  arbitrary shell commands while the add-on has `NET_ADMIN`.
- `SaveConfig` is rejected; the source of truth remains the Supervisor option.
- The add-on changes host routes and therefore requires `/dev/net/tun`, host
  networking, and `NET_ADMIN`. Review every imported profile before starting.
- DNS from the profile is applied through `resolvconf` for the add-on runtime;
  do not assume it reconfigures every Home Assistant container.
- Dynamic testing on a real Home Assistant OS host is still required before
  production use. Test first with a narrow, non-overlapping remote subnet and
  keep local console access available.

## Verification and recovery

After startup, the log must contain `AmneziaWG interface awg0 is ready`. Verify
access to one address inside `AllowedIPs` from a Home Assistant service that
shares the host network. A handshake occurs only when traffic is sent, so an
idle tunnel can legitimately show no recent handshake.

If local connectivity changes unexpectedly, stop the add-on. Its shutdown hook
runs `awg-quick down`, removes the userspace control socket, and stops the
userspace daemon. If the add-on cannot start, restore a narrow `AllowedIPs`
value and compare all Amnezia-specific fields with the exported client profile.

## Upstream versions and licenses

The image pins and verifies these upstream revisions during the build:

- `amneziawg-go` `v3.1.20260828`, commit
  `b5928efb6ca19f0153958460c3d141f04abc5c2e` (MIT);
- `amneziawg-tools` `v3.1.20260812`, commit
  `ee0f0a9aa34ff0a0da4b3433b9512781cfe02843` (GPL-2.0).

Their license files are copied into the runtime image. When publishing images,
retain the exact source references and satisfy the GPL corresponding-source
requirements for the `amneziawg-tools` binary.
