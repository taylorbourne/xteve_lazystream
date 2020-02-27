#!/bin/bash

export IP=$(getent ahostsv4 freegamez.ga | awk '{ print $1 }' | head -1)

docker build -t taylorbourne/xteve_lazystream \
	--add-host="mf.svc.nhl.com:$IP" \
	--add-host="playback.svcs.mlb.com:$IP" \
	--add-host="mlb-ws-mf.media.mlb.com:$IP" \
	.
