FROM alpine:3.22.1

RUN apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      jq \
      shadow \
      sudo \
    && \
    addgroup -S scronpt && \
    adduser -D -G scronpt -h /home/scronpt -S -s /bin/bash scronpt && \
    mkdir /etc/scronpt /var/lib/scronpt && \
    chown scronpt:scronpt /etc/scronpt /var/lib/scronpt && \
    chmod 700 /etc/scronpt /var/lib/scronpt && \
    rm -f /etc/crontabs/root && \
    curl --version

WORKDIR /

ENV SCRONPT_MINUTE="0" \
    SCRONPT_SCRIPT="/usr/local/bin/script"

COPY /docker/fs/ /

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
