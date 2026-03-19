# syntax=docker/dockerfile:1.7

FROM debian:bookworm-slim AS sandbox-base

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,id=openclaw-sandbox-bookworm-apt-cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=openclaw-sandbox-bookworm-apt-lists,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get upgrade -y --no-install-recommends \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    python3 \
    ripgrep

RUN useradd --create-home --shell /bin/bash sandbox

FROM sandbox-base AS sandbox-common

USER root

ENV DEBIAN_FRONTEND=noninteractive

ARG PACKAGES="curl wget jq coreutils grep nodejs npm python3 git ca-certificates golang-go rustc cargo unzip pkg-config libasound2-dev build-essential file"
ARG INSTALL_PNPM=1
ARG FINAL_USER=sandbox

RUN --mount=type=cache,id=openclaw-sandbox-common-apt-cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=openclaw-sandbox-common-apt-lists,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get upgrade -y --no-install-recommends \
  && apt-get install -y --no-install-recommends ${PACKAGES}

RUN if [ "${INSTALL_PNPM}" = "1" ]; then npm install -g pnpm; fi

USER ${FINAL_USER}
WORKDIR /home/${FINAL_USER}

CMD ["sleep", "infinity"]
