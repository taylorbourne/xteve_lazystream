FROM alpine:latest
RUN apk update
RUN apk upgrade
RUN apk add --no-cache ca-certificates

MAINTAINER taylorbourne taylorbourne@me.com.com

# Extras
RUN apk add --no-cache curl
RUN apk add openssl

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

# Add SSL certs for lazystream
# RUN openssl s_client -showcerts -connect freegamez.ga:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > /etc/ssl/certs/mf.svc.nhl.com.pem
# RUN openssl s_client -showcerts -connect freegamez.ga:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > /etc/ssl/certs/playback.svcs.mlb.com.pem
# RUN openssl s_client -showcerts -connect freegamez.ga:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > /etc/ssl/certs/mlb-ws-mf.media.mlb.com.pem

# Add xTeve and guide2go
RUN wget https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_amd64.zip -O temp.zip; unzip temp.zip -d /usr/bin/; rm temp.zip
ADD guide2go /usr/bin/guide2go

# Add lazystream
ADD lazystream /usr/bin/lazystream
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