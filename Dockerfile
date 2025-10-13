FROM --platform=$BUILDPLATFORM alpine:latest AS downloader
ARG VERSION_WSTUNNEL
ARG VERSION_TINI
ARG TARGETARCH

RUN apk --no-cache add ca-certificates

ADD https://github.com/krallin/tini/releases/download/v"${VERSION_TINI}"/tini-static-"${TARGETARCH}" /tmp/tini
ADD https://github.com/erebe/wstunnel/releases/download/v"${VERSION_WSTUNNEL}"/wstunnel_"${VERSION_WSTUNNEL}"_linux_"${TARGETARCH}".tar.gz /tmp/wstunnel.tar.gz
RUN tar -xvzf /tmp/wstunnel.tar.gz -C /tmp/



FROM scratch

ENV RUST_LOG="INFO"
ENV SERVER_PROTOCOL="wss"
ENV SERVER_LISTEN="[::]"
ENV SERVER_PORT="8080"
EXPOSE 8080

WORKDIR /bin
COPY --from=downloader --chmod=755 --chown=root  /tmp/wstunnel /bin/wstunnel
COPY --from=downloader --chmod=755 --chown=root  /tmp/tini /bin/tini
COPY --from=downloader --chmod=644 --chown=root  /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

ENTRYPOINT ["tini", "--"]
CMD ["wstunnel", "server", "${SERVER_PROTOCOL}://${SERVER_LISTEN}:${SERVER_PORT}"]