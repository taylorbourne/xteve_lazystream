FROM alpine:latest

RUN apk update
RUN apk upgrade
RUN apk add --no-cache ca-certificates

MAINTAINER taylorbourne taylorbourne@me.com.com

# Extras
RUN apk add --no-cache curl

# Timezone (TZ)
RUN apk update && apk add --no-cache tzdata
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add Bash shell & dependancies
RUN apk add --no-cache bash busybox-suid su-exec

# Volumes
VOLUME /config
VOLUME /playlists
VOLUME /guide2go
VOLUME /root/.xteve
VOLUME /tmp/xteve

# Add ffmpeg and vlc
RUN apk add ffmpeg
RUN apk add vlc
RUN sed -i 's/geteuid/getppid/' /usr/bin/vlc

# Add GNUtls so we can update certs
RUN apk add --no-cache gnutls-utils

# Add xTeve and guide2go
RUN wget https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_amd64.zip -O temp.zip; unzip temp.zip -d /usr/bin/; rm temp.zip
ADD guide2go /usr/bin/guide2go

# Add lazystream
RUN wget https://github.com/tarkah/lazystream/releases/download/v1.9.7/lazystream-v1.9.7-x86_64-unknown-linux-musl.tar.gz -O lazystream.tar.gz; \
    tar xzf lazystream.tar.gz; \
    mv lazystream/lazystream /usr/bin/lazystream; \
    rm lazystream.tar.gz; \
    rm -rf lazystream/

ADD cronjob.sh /
ADD entrypoint.sh /
ADD sample_cron.txt /
ADD sample_xteve.txt /

# Set executable permissions
RUN chmod +x /entrypoint.sh
RUN chmod +x /cronjob.sh
RUN chmod +x /usr/bin/lazystream
RUN chmod +x /usr/bin/xteve
RUN chmod +x /usr/bin/guide2go

# Expose Port
EXPOSE 34400

# Entrypoint
ENTRYPOINT ["./entrypoint.sh"]
