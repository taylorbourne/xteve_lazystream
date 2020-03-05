FROM alpine:latest

LABEL maintainer="taylorbourne taylorbourne@me.com.com"

# Install S6 overlay
ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

RUN apk upgrade --update --no-cache \
    && rm -rf /var/cache/apk/* \
    && tar xzf /tmp/s6overlay.tar.gz -C / \
    && rm /tmp/s6overlay.tar.gz


RUN apk add --no-cache ca-certificates curl tzdata bash coreutils shadow

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add ffmpeg and vlc
RUN apk add ffmpeg
RUN apk add vlc

# Add GNUtls so we can update certs
RUN apk add --no-cache gnutls-utils

# Add xTeve and guide2go
RUN wget https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_amd64.zip -O temp.zip; unzip temp.zip -d /usr/bin/; rm temp.zip

# Add lazystream
RUN wget https://github.com/tarkah/lazystream/releases/download/v1.9.7/lazystream-v1.9.7-x86_64-unknown-linux-musl.tar.gz -O lazystream.tar.gz; \
    tar xzf lazystream.tar.gz; \
    mv lazystream/lazystream /usr/bin/lazystream; \
    rm lazystream.tar.gz; \
    rm -rf lazystream/

# Add abc user
RUN groupmod -g 1000 users && \
    useradd -u 911 -U -d /home/abc -s /bin/bash abc && \
    usermod -G users abc

COPY root/ /

# Volumes
VOLUME /config
VOLUME /playlists
VOLUME /guide2go
VOLUME /xteve
VOLUME /tmp/xteve

# Set executable permissions
RUN chmod +x /usr/bin/lazystream
RUN chmod +x /usr/bin/xteve
RUN chmod +x /usr/bin/guide2go

# Expose Port
EXPOSE 34400

ENTRYPOINT [ "/init" ]