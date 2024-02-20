FROM alpine:latest as builder

RUN apk update \
    && apk add --no-cache \
        git \
        autoconf \
        automake \
        gcc \
        g++ \
        openssl-dev \
        zstd-dev \
        make \
        linux-headers \
    && rm -rf /var/cache/apk/*

WORKDIR /data
RUN git clone -b 2.8-stable https://github.com/ntop/n2n.git
WORKDIR /data/n2n
RUN ash ./autogen.sh
# RUN ./configures
RUN ./configure CFLAGS="-O3 -march=native"
RUN make

FROM alpine:latest

WORKDIR /data/n2n
COPY --from=builder /data/n2n/supernode .

EXPOSE 7654/udp
EXPOSE 5645/udp

ENTRYPOINT ["./supernode"]
