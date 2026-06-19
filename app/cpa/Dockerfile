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
        entry="${id}.so"; \
        [ "${3:-}" != "tagged" ] || entry="${id}-${tag}.so"; \
        mkdir -p "${TARGETOS}/${TARGETARCH}"; \
        curl -fsSLR -o "${archive}" "https://github.com/${repo}/releases/download/${tag}/${archive}"; \
        unzip -p "${archive}" "${entry}" > "${TARGETOS}/${TARGETARCH}/${id}.so"; \
        chmod 0755 "${TARGETOS}/${TARGETARCH}/${id}.so"; \
        rm -f "${archive}"; \
    }; \
    download_plugin jshandler router-for-me/cpa-plugin-jshandler; \
    download_plugin codexcomp uf-hy/cpa-plugin-codexcomp; \
    download_plugin cpa-account-config-manager Mxucc/cpa-account-config-manager tagged; \
    download_plugin cpa-codex-candy-eval haowang02/cpa-plugin-codex-candy-eval; \
    download_plugin privacyfilter rheodev/cpa-plugin-privacyfilter; \
    curl -fsSLR -o "${TARGETOS}/${TARGETARCH}/cpa-plugin-privacy-guard.so" \
        "https://s2.vpub.cc/cpa/plugins/${TARGETOS}/${TARGETARCH}/cpa-plugin-privacy-guard.so"; \
    chmod 0755 "${TARGETOS}/${TARGETARCH}/cpa-plugin-privacy-guard.so"

FROM eceasy/cli-proxy-api:${CPA_TAG}

COPY --from=plugins /plugins/ /CLIProxyAPI/plugins/
