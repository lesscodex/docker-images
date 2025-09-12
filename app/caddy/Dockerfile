FROM caddy:2-builder-alpine AS builder

RUN --mount=type=cache,target=/go/pkg/mod \
    # xcaddy build v2.9.1 \
    xcaddy build \
        --with github.com/caddyserver/jsonc-adapter \
        --with github.com/mholt/caddy-l4/layer4 \
        --with github.com/mholt/caddy-l4/modules/l4tls \
        --with github.com/mholt/caddy-l4/modules/l4proxy \
        # --with github.com/caddy-dns/cloudflare@v0.1.0 \
        --with github.com/caddy-dns/cloudflare \
        # --with github.com/caddy-dns/alidns@v1.0.25 \
        --with github.com/caddy-dns/alidns \
        --with github.com/WeidiDeng/caddy-cloudflare-ip \
        --with github.com/caddyserver/cache-handler

FROM caddy:2-alpine
LABEL org.opencontainers.image.authors="xy@lesscode.dev"
# LABEL org.opencontainers.image.source=https://github.com/lesscodex/docker-images

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
