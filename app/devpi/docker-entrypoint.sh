#!/usr/bin/env sh

set -e

if [ -z "${DEVPISERVER_HOST}" ]; then
    DEVPISERVER_HOST="0.0.0.0"
fi

if [ ! -f "${DEVPISERVER_SERVERDIR}/.nodeinfo" ]; then
    echo "start initialization"
    devpi-init --no-root-pypi

    (
        echo "waiting for devpi-server start"
        sleep 10
        devpi use "http://${DEVPISERVER_HOST}:3141"
        devpi login root --password=""
        devpi user -m root password="${DEVPISERVER_ROOT_PASSWORD}"

        echo "create user ${DEVPISERVER_USER}"
        devpi user -c "${DEVPISERVER_USER}" password="${DEVPISERVER_PASSWORD}"
        devpi logout  # logout from root
        devpi login "${DEVPISERVER_USER}" --password="${DEVPISERVER_PASSWORD}"

        devpi index -c ${DEVPISERVER_USER}/pypi type=mirror mirror_url="${SOURCE_MIRROR_URL}" mirror_web_url_fmt="${SOURCE_MIRROR_URL}/{name}/"
        devpi index -c devpi bases="${DEVPISERVER_USER}/pypi"

        devpi logout
    ) &

else
    echo "skip initialization"
fi

exec devpi-server --host="${DEVPISERVER_HOST}" $@
