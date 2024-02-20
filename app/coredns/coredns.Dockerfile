FROM coredns/coredns:latest


FROM golang:latest

RUN git clone --depth 1 --branch v1.11.1 \
        https://github.com/coredns/coredns
WORKDIR /go/coredns
# A very common mistake is to add external plugins to the end of the list,
# but plugin.cfg defines execution order of plugins.
COPY plugin.cfg ./plugin.cfg
# local proxy
# RUN go env -w GO111MODULE=on && \
#     go env -w GOPROXY=https://goproxy.cn,direct
# go version > 1.16 go mod tidy
RUN go get github.com/coredns/alternate && \
    go generate && go mod tidy && go build && make


FROM scratch

COPY --from=0 /etc/ssl/certs /etc/ssl/certs
COPY --from=1 /go/coredns/coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
