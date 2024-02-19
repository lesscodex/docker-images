FROM ubuntu:latest
LABEL maintainer="xxy1991"

COPY app/apt-cacher.sh ./
RUN sh apt-cacher.sh && rm apt-cacher.sh

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
    apt-get -yqq --no-install-recommends install \
    python3-pip python3-venv sudo \
    && rm -f /etc/apt/apt.conf \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get -qq clean && rm -rf /var/lib/apt/lists/*

ENV USERNAME=xy USER_UID=1000 USER_GID=1000
RUN set -xe \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd -m --uid ${USER_UID} --gid ${USER_GID} ${USERNAME} \
    && usermod -aG sudo ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
