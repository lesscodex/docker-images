FROM docker:latest

RUN apk add --no-cache \
        py3-pip \
        ansible

RUN apk add --no-cache --virtual .build-deps \
        build-base \
        python3-dev \
        libffi-dev \
        openssl-dev \
        linux-headers
