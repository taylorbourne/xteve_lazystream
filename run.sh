#!/bin/bash

docker run -d \
	--name=xteve_lazystream \
	-p 34400:34400 \
	--env-file=.env \
	--log-opt max-size=10m \
	--log-opt max-file=3 \
	-e TZ="America/Los_Angeles" \
	-v /mnt/user/appdata/xteve/.xteve:/xteve:rw \
	-v /mnt/user/appdata/xteve/config/:/config:rw \
	-v /mnt/user/appdata/xteve/guide2go/:/guide2go:rw \
	-v /mnt/user/appdata/xteve/playlists/:/playlists:rw \
	-v /tmp/xteve/:/tmp/xteve:rw \
	taylorbourne/xteve_lazystream
