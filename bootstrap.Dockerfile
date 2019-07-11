FROM alpine:latest

RUN apk add --no-cache curl openssl && \
    wget -O /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
    chmod +x /usr/bin/jq
