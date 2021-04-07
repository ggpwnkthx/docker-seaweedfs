FROM alpine:3 as builder
RUN apk add --no-cache --virtual wget curl ca-certificates
ARG RELEASE=latest
RUN \
    ARCH=$(if [ $(uname -m) == "x86_64" ] && [ $(getconf LONG_BIT) == "64" ]; then echo "amd64"; \
         elif [ $(uname -m) == "x86_64" ] && [ $(getconf LONG_BIT) == "32" ]; then echo "386"; \
         elif [ $(uname -m) == "aarch64" ]; then echo "arm64"; \
         elif [ $(uname -m) == "armv7l" ]; then echo "arm"; \
         elif [ $(uname -m) == "armv6l" ]; then echo "arm"; fi;) && \
    wget -P /tmp https://github.com/$(curl -s -L https://github.com/chrislusf/seaweedfs/releases/${RELEASE} | egrep -o "chrislusf/seaweedfs/releases/download/.*/linux_$ARCH.tar.gz") && \
    tar -C /usr/bin/ -xzvf /tmp/linux_$ARCH.tar.gz

COPY ./entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

FROM alpine:3
RUN apk add --no-cache fuse
RUN mkdir -p /var/run/docker/plugins/seaweedfs
COPY --from=builder /usr/bin/weed /usr/bin/
COPY --from=builder /bin/entrypoint.sh /bin/
ENTRYPOINT [ "/bin/entrypoint.sh" ]