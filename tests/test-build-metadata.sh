#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dockerfile="${project_dir}/amnezia_client/Dockerfile"

if [[ -e "${project_dir}/amnezia_client/build.yaml" ]]; then
    echo "Deprecated amnezia_client/build.yaml must not exist" >&2
    exit 1
fi

grep -Fq 'FROM ghcr.io/hassio-addons/base:21.0.8' "${dockerfile}"

if grep -Eq '^[[:space:]]*ARG[[:space:]]+BUILD_FROM' "${dockerfile}"; then
    echo "Dockerfile must not depend on the legacy BUILD_FROM argument" >&2
    exit 1
fi

grep -Fq 'version: 0.1.1' "${project_dir}/amnezia_client/config.yaml"

echo "Build metadata tests passed"
