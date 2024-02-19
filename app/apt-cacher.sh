#!/bin/sh

APT_PROXY_IP=10.146.5.57
APT_PROXY_PORT=3142
APT_PROXY=$APT_PROXY_IP:$APT_PROXY_PORT

ping -c 1 $APT_PROXY_IP > /dev/null 2>&1
if [ $? -eq 0 ];then
    echo "Acquire::http::Proxy \"http://$APT_PROXY\";" > /etc/apt/apt.conf
else
    rm -f /etc/apt/apt.conf
fi

if [ $1 ];then
    exec "$@"
fi
