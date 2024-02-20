FROM ubuntu:bionic

VOLUME ["/var/cache/apt-cacher-ng"]
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
    apt-get -yqq install apt-cacher-ng

RUN echo 'PassThroughPattern: ^(.*):443$' \
    >> /etc/apt-cacher-ng/acng.conf && \
    echo 'mirrors.aliyun.com/debian' \
    >> /etc/apt-cacher-ng/backends_debian && \
    echo 'mirrors.aliyun.com/ubuntu' \
    >> /etc/apt-cacher-ng/backends_debian

EXPOSE 3142
CMD chmod 777 /var/cache/apt-cacher-ng && \
    /etc/init.d/apt-cacher-ng start && \
    tail -f /var/log/apt-cacher-ng/*
