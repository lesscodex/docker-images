FROM xxy1991/debian:ssh
LABEL maintainer="xxy1991"
ENV container=docker

COPY app/apt-cacher.sh ./
RUN sh apt-cacher.sh && rm apt-cacher.sh

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
    apt-get -yqq --no-install-recommends install \
            python3-pip \
            python3-venv && \
    rm -f /etc/apt/apt.conf && \
    rm -Rf /usr/share/doc && rm -Rf /usr/share/man
