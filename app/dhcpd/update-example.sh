#!/usr/bin/env bash

docker build -t xxy1991/isc-dhcpd:alpine . -f alpine.Dockerfile

docker run -d -i --name dhcpd xxy1991/isc-dhcpd:alpine

docker cp dhcpd:"/etc/dhcp/dhcpd.conf.example" "./dhcpd.conf.example"
docker container stop dhcpd
docker container rm dhcpd
