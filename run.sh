#!/bin/bash

export IP=$(getent ahostsv4 freegamez.ga | awk '{ print $1 }' | head -1)

docker run -d \
	  --name=xteve_lazystream \
	  --log-opt max-size=10m \
	  --log-opt max-file=3 \
	  -e TZ="America/Los_Angeles" \
	  -v /mnt/user/appdata/xteve/:/root/.xteve:rw \
	  -v /mnt/user/appdata/xteve/_config/:/config:rw \
	  -v /mnt/user/appdata/xteve/_guide2go/:/guide2go:rw \
          -v /mnt/user/appdata/xteve/playlists/:/playlists:rw \
	  -v /tmp/xteve/:/tmp/xteve:rw \
          --add-host="mf.svc.nhl.com:$IP" \
	  --add-host="playback.svcs.mlb.com:$IP" \
	  --add-host="mlb-ws-mf.media.mlb.com:$IP" \
	  taylorbourne/xteve_lazystream
