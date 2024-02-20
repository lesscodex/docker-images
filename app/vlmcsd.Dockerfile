FROM alpine:latest as builder

RUN apk update \
    && apk upgrade \
    && apk add --no-cache build-base gcc abuild binutils cmake git \
    && cd / \
    && git clone https://github.com/kkkgo/vlmcsd.git \
    && cd vlmcsd \
    && make vlmcsdmulti \
    && chmod +x bin/vlmcsdmulti \
    && mv bin/vlmcsdmulti / \
    && cd / \
    && apk del build-base gcc abuild binutils cmake git \
    && rm -rf /vlmcsd  \
    && rm -rf /var/cache/apk/*

FROM alpine:latest

COPY --from=builder /vlmcsdmulti /vlmcsdmulti
RUN chmod +x /vlmcsdmulti

EXPOSE 1688
ENTRYPOINT ["/vlmcsdmulti", "vlmcsd", "-vDe"]
