#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_IMAGE="${TARGET_IMAGE:-openclaw-sandbox:bookworm-slim}"
PACKAGES="${PACKAGES:-curl wget jq coreutils grep nodejs npm python3 git ca-certificates golang-go rustc cargo unzip pkg-config libasound2-dev build-essential file}"
INSTALL_PNPM="${INSTALL_PNPM:-1}"
FINAL_USER="${FINAL_USER:-sandbox}"
OPENCLAW_DOCKER_BUILD_USE_BUILDX="${OPENCLAW_DOCKER_BUILD_USE_BUILDX:-0}"
OPENCLAW_DOCKER_BUILD_CACHE_FROM="${OPENCLAW_DOCKER_BUILD_CACHE_FROM:-}"
OPENCLAW_DOCKER_BUILD_CACHE_TO="${OPENCLAW_DOCKER_BUILD_CACHE_TO:-}"

build_cmd=(docker build)
if [ "${OPENCLAW_DOCKER_BUILD_USE_BUILDX}" = "1" ]; then
  build_cmd=(docker buildx build --load)
  if [ -n "${OPENCLAW_DOCKER_BUILD_CACHE_FROM}" ]; then
    build_cmd+=(--cache-from "${OPENCLAW_DOCKER_BUILD_CACHE_FROM}")
  fi
  if [ -n "${OPENCLAW_DOCKER_BUILD_CACHE_TO}" ]; then
    build_cmd+=(--cache-to "${OPENCLAW_DOCKER_BUILD_CACHE_TO}")
  fi
fi

"${build_cmd[@]}" \
  -t "${TARGET_IMAGE}" \
  -f "${SCRIPT_DIR}/openclaw-sandbox.Dockerfile" \
  --build-arg PACKAGES="${PACKAGES}" \
  --build-arg INSTALL_PNPM="${INSTALL_PNPM}" \
  --build-arg FINAL_USER="${FINAL_USER}" \
  "${SCRIPT_DIR}"

echo "Built ${TARGET_IMAGE}"
