FROM alpine:3.20

RUN apk update \
    && apk add --no-cache \
        dhcp \
    && rm -rf /var/cache/apk/*

EXPOSE \
    # ipv4
    67/udp \
    # ipv6
    547/udp \
    # dhcp-failover primary
    674/tcp \
    # dhcp-failover peer
    874/tcp

RUN touch /var/lib/dhcp/dhcpd.leases

# -f=front -d=stdout
CMD ["/usr/sbin/dhcpd", \
    "-4", "-f", "-d", \
    "-cf", "/etc/dhcp/dhcpd.conf"]
