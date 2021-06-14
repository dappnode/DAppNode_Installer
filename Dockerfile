FROM docker:dind

RUN apk update && \
    apk add xorriso git xz curl ca-certificates iptables cpio bash \
    docker-compose && \
    rm -rf /var/cache/apk/* 

#RUN apk add -U --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing aufs-util

RUN addgroup -g 2999 docker

# Create app directory
WORKDIR /usr/src/app
ADD . .

CMD ["/usr/src/app/iso/scripts/generate_ISO.sh"] 