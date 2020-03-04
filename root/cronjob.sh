#!/bin/bash

set -o allexport
source /config/.env
set +o allexport

echo "Running scripts..."

XTEVE_PORT=${XTEVE_PORT:-34400}

### Generate playlist and XML data from Lazystream
if [ "$use_lazystream" = "yes" ]; then

	if [ "$include_nhl" = "yes" ]; then
		echo "Running Lazystream (NHL)..."
		mkdir -p /playlists/lazystream
		lazystream generate xmltv \
			--channel-prefix Lazystream:\ NHL \
			--start-channel 1000 \
			/playlists/lazystream/lazystream-nhl
	fi
	if [ "$include_mlb" = "yes" ]; then
		echo "Running Lazystream (MLB)..."
		mkdir -p /playlists/lazystream
		lazystream --sport mlb generate xmltv \
			--channel-prefix Lazystream:\ MLB \
			--start-channel 2000 \
			/playlists/lazystream/lazystream-mlb
	fi
fi

# run guide2go in a loop
if [ "$use_guide2go" = "yes" ]; then
	echo "Running guide2Go..."
	for jsons in $JsonList
		do
		jsonefile="${jsons%.*}"
		filecache='  "file.cache": "/guide2go/cache_'$jsons'",'
		fileoutput='  "file.output": "/guide2go/'$jsonefile'.xml",'
		sed -i "/file.cache/c $filecache" /guide2go/$jsons
		sed -i "/file.output/c $fileoutput" /guide2go/$jsons
		guide2go -config /guide2go/$jsons
	done
fi

sleep 1

# update xteve via API
if [ "$use_xTeveAPI" = "yes" ]; then
	echo "Updating xTeVe..."
	curl -X POST -d '{"cmd":"update.m3u"}' http://127.0.0.1:$XTEVE_PORT/api/
	sleep 1
	curl -X POST -d '{"cmd":"update.xmltv"}' http://127.0.0.1:$XTEVE_PORT/api/
	sleep 1
	curl -X POST -d '{"cmd":"update.xepg"}' http://127.0.0.1:$XTEVE_PORT/api/
	sleep 1
fi

# update Emby via API
if [ "$use_embyAPI" = "yes" ]; then
	echo "Updating Emby..."
	if [ -z "$embyIP" ]; then
		echo "no Emby credentials provided"
	else
		curl -X POST "http://$embyIP:$embyPORT/emby/ScheduledTasks/Running/$embyID?api_key=$embyApiKey" -H "accept: */*" -d ""
		sleep 1
	fi
fi

# update Plex via API
if [ "$use_plexAPI" = "yes" ]; then
	echo "Updating Plex..."
	if [ -z "$plexIP" ]; then
		echo "no Plex credentials provided"
	else
		curl -X POST "http://$plexIP:$plexPORT/livetv/dvrs/$plexID/reloadGuide?X-Plex-Token=$plexToken"
		sleep 1
	fi
fi

exit