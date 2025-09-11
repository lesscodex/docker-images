#!/bin/sh

SET_HTTP_PROXY=false
SET_HTTPS_PROXY=false

if [ -n "$APT_HTTP_PROXY" ]; then
    # ping -c 1 ${APT_HTTP_PROXY%%:*} > /dev/null 2>&1
    # if [ $? -eq 0 ];then
        SET_HTTP_PROXY=true
    # fi
fi

if [ -n "$APT_HTTPS_PROXY" ]; then
    # ping -c 1 ${APT_HTTPS_PROXY%%:*} > /dev/null 2>&1
    # if [ $? -eq 0 ];then
        SET_HTTPS_PROXY=true
    # fi
fi

if $SET_HTTP_PROXY || $SET_HTTPS_PROXY; then
    if $SET_HTTP_PROXY;then
        echo "Acquire::http::Proxy \"http://$APT_HTTP_PROXY\";" > /etc/apt/apt.conf.d/proxy.conf
    fi
    if $SET_HTTPS_PROXY; then
        echo "Acquire::https::Proxy \"http://$APT_HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf
    fi
else
    rm -f /etc/apt/apt.conf.d/proxy.conf
fi
