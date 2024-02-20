FROM python:3-alpine as builder

RUN apk --update add --no-cache \
        gcc musl-dev libffi-dev && \
    rm -rf /var/cache/apk/*

RUN pip3 install -q -U pip && \
    pip3 wheel -q --wheel-dir=/srv/wheels \
    devpi-server devpi-web devpi-client

FROM python:3-alpine
LABEL maintainer="xxy1991"
ENV container=docker

WORKDIR /opt/devpi
COPY --from=builder /srv/wheels /srv/wheels
RUN pip3 install -q --no-cache-dir --no-index --find-links=/srv/wheels \
    devpi-server devpi-web devpi-client

ENV DEVPISERVER_SERVERDIR=/var/lib/devpi
VOLUME /var/lib/devpi
EXPOSE 3141
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh
# USER 1000:1000
ENTRYPOINT ["./docker-entrypoint.sh"]
