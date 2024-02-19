FROM ubuntu:latest
LABEL maintainer="xxy1991"
ENV container=docker

COPY app/apt-cacher.sh ./
RUN sh apt-cacher.sh && rm apt-cacher.sh

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
    apt-get -yqq install \
            build-essential \
            git \
            curl && \
    rm -f /etc/apt/apt.conf
