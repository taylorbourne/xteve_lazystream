FROM arm64v8/alpine:latest

LABEL maintainer="taylorbourne taylorbourne@me.com.com"

# Install S6 overlay
ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-aarch64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

RUN tar xzf /tmp/s6overlay.tar.gz -C / \
    && rm /tmp/s6overlay.tar.gz

# Add packages
RUN apk upgrade --update --no-cache \
    && apk add --no-cache \
            ca-certificates \
            curl \
            tzdata \
            bash \
            coreutils \
            shadow \
            ffmpeg \
            vlc \
            gnutls-utils

# pi4 library to run lazystream: https://github.com/ljfranklin/alpine-pkg-glibc/releases/tag/2.32-r0-arm64
RUN wget https://github.com/ljfranklin/alpine-pkg-glibc/releases/download/2.32-r0-arm64/glibc-2.32-r0.apk
RUN apk add --allow-untrusted glibc-2.32-r0.apk

RUN wget https://github.com/ljfranklin/alpine-pkg-glibc/releases/download/2.32-r0-arm64/glibc-bin-2.32-r0.apk
RUN apk add --allow-untrusted glibc-bin-2.32-r0.apk

RUN wget https://github.com/ljfranklin/alpine-pkg-glibc/releases/download/2.32-r0-arm64/glibc-i18n-2.32-r0.apk
RUN apk add --allow-untrusted glibc-i18n-2.32-r0.apk
                       
# Update Timezone
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add xTeve and guide2go
RUN wget https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_arm64.zip -O temp.zip; unzip temp.zip -d /usr/bin/; rm temp.zip

# Add lazystream
RUN wget https://github.com/tarkah/lazystream/releases/download/v1.11.4/lazystream-v1.11.4-aarch64-unknown-linux-gnu.tar.gz -O lazystream.tar.gz; \
    tar xzf lazystream.tar.gz; \
    mv ././lazystream /usr/bin/lazystream; \
    rm lazystream.tar.gz; \
    rm -rf lazystream/

# Add abc user
RUN groupmod -g 1000 users && \
    useradd -u 911 -U -d /home/abc -s /bin/bash abc && \
    usermod -G users abc

# Copy root folder
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

# Build arg
ARG XTEVE_PORT=34400

# Env
ENV PUID=1000 \
    PGID=1000 \
    XTEVE_PORT=${XTEVE_PORT} \
    use_xTeveAPI=yes \
    use_lazystream=yes \
    include_nhl=yes\
    include_mlb=yes \
    cdn=akc \
    use_guide2go=no \
    YamlList="CBLguide.yaml SATguide.yaml SATSport.yaml" \
    use_embyAPI=no \
    embyIP= \ 
    embyPORT=8096 \
    embyApiKey= \
    embyID= \
    use_plexAPI=no

# Expose Port
EXPOSE ${XTEVE_PORT}

ENTRYPOINT [ "/init" ]
