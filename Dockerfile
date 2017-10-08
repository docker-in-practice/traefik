FROM golang:1.9-alpine as builder
# See: https://github.com/containous/traefik/blob/master/CONTRIBUTING.md
RUN apk --update upgrade && apk --no-cache --no-progress add git mercurial bash gcc musl-dev curl tar && rm -rf /var/cache/apk/*
RUN mkdir -p /go/src/github.com/containous
WORKDIR /go/src/github.com/containous
RUN git clone https://github.com/containous/traefik
RUN echo 'GOPATH=/go' >> /root/.bashrc
RUN bash -c 'echo "PATH=$PATH:$GOPATH" >> /root/.bashrc'
WORKDIR /go/src/github.com/containous/traefik
RUN go get github.com/jteeuwen/go-bindata/...
RUN go generate
RUN go build ./cmd/traefik
#RUN go test ./...
RUN apk --no-cache add ca-certificates

FROM scratch
COPY --from=builder /go/src/github.com/containous/traefik/traefik /traefik
COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs
EXPOSE 80
ENTRYPOINT ["/traefik"]
