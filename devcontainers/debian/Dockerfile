FROM mcr.microsoft.com/devcontainers/base:debian-13

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
        apt-get -yqq --no-install-recommends install \
        curl ca-certificates \
        ripgrep && \
        rm -rf /var/lib/apt/lists/* && \
        rm -Rf /usr/share/doc && rm -Rf /usr/share/man

COPY --from=public.ecr.aws/docker/library/node:24-trixie-slim /usr/local/bin/node /usr/local/bin/node
COPY --from=public.ecr.aws/docker/library/node:24-trixie-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
        ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
        ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
        ln -s /usr/local/lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack 

RUN npm i -g @google/gemini-cli @augmentcode/auggie@prerelease
