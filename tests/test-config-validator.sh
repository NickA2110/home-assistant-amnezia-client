#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
validator="${project_dir}/amnezia_client/rootfs/usr/local/bin/validate-awg-config"
test_dir="$(mktemp -d)"
trap 'rm -rf "${test_dir}"' EXIT

write_valid_config() {
    local target="$1"
    cat > "${target}" <<'EOF'
[Interface]
PrivateKey = client-private-key
Address = 10.8.1.2/32
Jc = 4
Jmin = 10
Jmax = 50
S1 = 98
S2 = 52
S3 = 33
S4 = 15
H1 = 100-200
H2 = 300-400
H3 = 500-600
H4 = 700-800
I1 = <r 2><b 0x0102>
HeaderProtectionKey = AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
ContentPaddingAddition = 0-16
RekeyAfterTime = 120-180
RandomTrailers = true

[Peer]
PublicKey = server-public-key
PresharedKey = shared-key
Endpoint = vpn.example.com:51820
AllowedIPs = 10.8.1.0/24, 172.16.50.0/24
PersistentKeepalive = 25
EOF
}

assert_rejected() {
    local name="$1"
    local expected="$2"
    if "${validator}" "${test_dir}/${name}.conf" >"${test_dir}/${name}.out" 2>&1; then
        echo "Expected ${name} to be rejected" >&2
        exit 1
    fi
    grep -Fq "${expected}" "${test_dir}/${name}.out"
}

write_valid_config "${test_dir}/valid.conf"
"${validator}" "${test_dir}/valid.conf"

write_valid_config "${test_dir}/default-route.conf"
sed -i 's#10.8.1.0/24, 172.16.50.0/24#0.0.0.0/0#' "${test_dir}/default-route.conf"
assert_rejected default-route "Default routes are not supported"

write_valid_config "${test_dir}/ipv6-default-route.conf"
sed -i 's#10.8.1.0/24, 172.16.50.0/24#10.8.1.0/24, ::/0#' "${test_dir}/ipv6-default-route.conf"
assert_rejected ipv6-default-route "Default routes are not supported"

write_valid_config "${test_dir}/hook.conf"
sed -i '/Address/a PostUp = touch /tmp/unsafe' "${test_dir}/hook.conf"
assert_rejected hook "PostUp is not allowed"

write_valid_config "${test_dir}/missing-endpoint.conf"
sed -i '/Endpoint/d' "${test_dir}/missing-endpoint.conf"
assert_rejected missing-endpoint "requires PublicKey, Endpoint, and AllowedIPs"

write_valid_config "${test_dir}/missing-key.conf"
sed -i 's/PrivateKey = client-private-key/PrivateKey =/' "${test_dir}/missing-key.conf"
assert_rejected missing-key "requires a non-empty PrivateKey"

echo "Config validator tests passed"
