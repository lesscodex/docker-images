ARG MIHOMO_VERSION=latest

FROM --platform=$BUILDPLATFORM alpine:latest AS builder

RUN apk add --no-cache curl jq

ARG TARGETARCH
ARG MIHOMO_VERSION

WORKDIR /build

RUN set -eu; \
    api="https://api.github.com/repos/MetaCubeX/mihomo/releases"; \
    if [ "$MIHOMO_VERSION" = latest ]; then \
        release="$(curl -fsSL "$api/latest")"; \
    else \
        release="$(curl -fsSL "$api/tags/$MIHOMO_VERSION")"; \
    fi; \
    version="$(printf '%s' "$release" | jq -er '.tag_name')"; \
    asset="mihomo-linux-${TARGETARCH}-${version}.gz"; \
    url="$(printf '%s' "$release" | jq -er --arg name "$asset" '.assets[] | select(.name == $name) | .browser_download_url')"; \
    checksum="$(printf '%s' "$release" | jq -er --arg name "$asset" '.assets[] | select(.name == $name) | .digest | ltrimstr("sha256:")')"; \
    curl -fsSL "$url" -o mihomo.gz; \
    printf '%s  mihomo.gz\n' "$checksum" | sha256sum -c -; \
    gzip -d mihomo.gz; \
    mkdir runtime; \
    printf '%s\n' "$version" > runtime/upstream-version

FROM gcr.io/distroless/static:nonroot

ARG MIHOMO_VERSION
LABEL org.opencontainers.image.title="Mihomo Rootless" \
      org.opencontainers.image.description="Rootless distroless runtime for Mihomo" \
      org.opencontainers.image.version="${MIHOMO_VERSION}" \
      org.opencontainers.image.source="https://github.com/MetaCubeX/mihomo" \
      org.opencontainers.image.licenses="GPL-3.0"

COPY --from=builder --chown=0:0 --chmod=0555 /build/mihomo /usr/local/bin/mihomo
COPY --from=builder --chown=65532:65532 /build/runtime/ /var/lib/mihomo/

WORKDIR /var/lib/mihomo
USER 65532:65532

ENTRYPOINT ["/usr/local/bin/mihomo"]
CMD ["-d", "/var/lib/mihomo", "-f", "/etc/mihomo/config.yaml"]
