# syntax=docker/dockerfile:1

FROM golang:1.25-alpine3.22 AS builder

ARG AWG_GO_VERSION=v3.1.20260828
ARG AWG_GO_COMMIT=b5928efb6ca19f0153958460c3d141f04abc5c2e
ARG AWG_TOOLS_VERSION=v3.1.20260812
ARG AWG_TOOLS_COMMIT=ee0f0a9aa34ff0a0da4b3433b9512781cfe02843

RUN apk add --no-cache build-base git linux-headers

WORKDIR /build

RUN git clone --depth 1 --branch "${AWG_GO_VERSION}" \
        https://github.com/amnezia-vpn/amneziawg-go.git \
    && test "$(git -C amneziawg-go rev-parse HEAD)" = "${AWG_GO_COMMIT}" \
    && git clone --depth 1 --branch "${AWG_TOOLS_VERSION}" \
        https://github.com/amnezia-vpn/amneziawg-tools.git \
    && test "$(git -C amneziawg-tools rev-parse HEAD)" = "${AWG_TOOLS_COMMIT}"

RUN CGO_ENABLED=0 make -C amneziawg-go \
    && make -C amneziawg-tools/src \
    && install -Dm755 amneziawg-go/amneziawg-go \
        /out/usr/local/bin/amneziawg-go \
    && install -Dm755 amneziawg-tools/src/wg \
        /out/usr/local/bin/awg \
    && install -Dm755 amneziawg-tools/src/wg-quick/linux.bash \
        /out/usr/local/bin/awg-quick


ARG BUILD_FROM=ghcr.io/hassio-addons/base:21.0.8
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk add --no-cache \
        bash \
        iproute2 \
        iptables \
        openresolv \
        procps-ng \
    && ln -sf /sbin/xtables-nft-multi /sbin/ip6tables \
    && ln -sf /sbin/xtables-nft-multi /sbin/iptables

COPY --from=builder /out/ /
COPY --from=builder /build/amneziawg-go/LICENSE \
    /usr/share/licenses/amneziawg-go/LICENSE
COPY --from=builder /build/amneziawg-tools/COPYING \
    /usr/share/licenses/amneziawg-tools/COPYING
COPY rootfs /

ENV WG_QUICK_USERSPACE_IMPLEMENTATION=amneziawg-go
ENV PATH="/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin"

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

LABEL \
    io.hass.name="AmneziaWG Client" \
    io.hass.description="Userspace AmneziaWG split-tunnel client" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="NickA2110 <https://github.com/NickA2110>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.version="${BUILD_VERSION}" \
    org.opencontainers.image.licenses="MIT AND GPL-2.0-only" \
    org.opencontainers.image.url="https://github.com/NickA2110/home-assistant-amnezia-client" \
    org.opencontainers.image.documentation="https://github.com/NickA2110/home-assistant-amnezia-client/blob/main/amnezia_client/DOCS.md" \
    org.opencontainers.image.source="https://github.com/NickA2110/home-assistant-amnezia-client"
