ARG CPA_TAG=latest

FROM alpine:latest AS plugins

RUN apk add --no-cache ca-certificates curl unzip

ARG TARGETOS=linux
ARG TARGETARCH=amd64

WORKDIR /plugins

RUN set -eu; \
    download_plugin() { \
        id="$1"; \
        repo="$2"; \
        tag="$(basename "$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/${repo}/releases/latest")")"; \
        version="${tag#v}"; \
        archive="${id}_${version}_${TARGETOS}_${TARGETARCH}.zip"; \
        mkdir -p "${TARGETOS}/${TARGETARCH}"; \
        curl -fsSLR -o "${archive}" "https://github.com/${repo}/releases/download/${tag}/${archive}"; \
        unzip -p "${archive}" "${id}.so" > "${TARGETOS}/${TARGETARCH}/${id}.so"; \
        chmod 0755 "${TARGETOS}/${TARGETARCH}/${id}.so"; \
        rm -f "${archive}"; \
    }; \
    download_plugin jshandler router-for-me/cpa-plugin-jshandler; \
    download_plugin privacyfilter rheodev/cpa-plugin-privacyfilter

FROM eceasy/cli-proxy-api:${CPA_TAG}

COPY --from=plugins /plugins/ /CLIProxyAPI/plugins/
