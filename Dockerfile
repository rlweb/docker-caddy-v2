#
# Builder
#
FROM golang:1.12-alpine3.10 as builder

LABEL maintainer="Rhys Laval <rhyslaval@gmail.com>"

# Install the Certificate-Authority certificates for the app to be able to make
# calls to HTTPS endpoints.
# Git is required for fetching the dependencies.
RUN apk add --no-cache ca-certificates git

WORKDIR /src
RUN git clone -b v2 "https://github.com/caddyserver/caddy.git" /src
# Build the executable to `/caddy`. Mark the build as statically linked.
RUN cd cmd/caddy && \
    CGO_ENABLED=0 go build \
    -installsuffix 'static' \
    -o /caddy .

#
# Final
#
FROM scratch AS final

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /caddy /caddy

ENTRYPOINT ["/caddy"]
CMD ["start", "--config", "/etc/caddy.json"]
