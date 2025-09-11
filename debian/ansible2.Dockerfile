FROM debian:stable-slim
LABEL maintainer="xxy1991"

ARG APT_HTTP_PROXY
ARG APT_HTTPS_PROXY

ENV APT_HTTP_PROXY=$APT_HTTP_PROXY \
    APT_HTTPS_PROXY=$APT_HTTPS_PROXY

# RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
#     apt-get -yqq --no-install-recommends install \
#     iputils-ping
COPY files/proxy.sh /usr/local/share/proxy.sh
RUN chmod +x /usr/local/share/proxy.sh

RUN /usr/local/share/proxy.sh && \
    apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
    apt-get -yqq --no-install-recommends install \
    python3-pip python3-venv sudo \
    && rm -f /etc/apt/apt.conf.d/proxy.conf \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get -qq clean && rm -rf /var/lib/apt/lists/*

ENV USERNAME=auser USER_UID=1000 USER_GID=1000
RUN set -xe \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd -m --uid ${USER_UID} --gid ${USER_GID} ${USERNAME} \
    && usermod -aG sudo ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

COPY files/docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

USER ${USERNAME}
ENTRYPOINT [ "./docker-entrypoint.sh" ]
