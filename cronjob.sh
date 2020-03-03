#!/bin/bash
echo "Running scripts..."

##### Config
use_embyAPI="no"
use_guide2go="no"
use_lazystream="no"
use_plexAPI="no"
use_xTeveAPI="yes"

##### Lazystream Config
include_nhl="no"
include_mlb="no"

### List of created lineup json files in /guide2go
# Exmaple with 3 lineups
JsonList="CBLguide.json SATguide.json SATSport.json"

### to create your lineups run the below command and follow the on-screen instructions
# docker exec -it <yourdockername> guide2go -configure /guide2go/<lineupnamehere>.json

### xTeVe
xTeveIP="192.168.1.2"
xTevePORT="34400"

### Emby
# Only necessary if xTeVe API is active
# API Key, https://github.com/MediaBrowser/Emby/wiki/Api-Key-Authentication
# embyID, settings, scroll down click API, Scheduled Task Service, GET /ScheduledTasks, Try, Execute, look for "Refresh Guide" ID, sample here 9492d30c70f7f1bec3757c9d0a4feb45
embyIP="192.168.1.2"
embyPORT="8096"
embyApiKey=""
embyID="9492d30c70f7f1bec3757c9d0a4feb45"

### Plex
# Only necessary if xTeVe API is active
# Finding your Plex token: https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/
# Finding Plex ID: http://YOUR_IP_HERE:32400/?X-Plex-Token=YOUR_TOKEN_HERE , look for "tv.plex.providers.epg.xmltv:  " and enter the value blow.
plexIP="192.168.1.2"
plexPORT="32400"
plexToken=""
plexID=""

# cronjob, check sample_cron.txt with an editor to adjust time

### END Config
##
#

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
	if [ -z "$xTeveIP" ]; then
		echo "no xTeve credentials provided"
	else
		curl -X POST -d '{"cmd":"update.m3u"}' http://$xTeveIP:$xTevePORT/api/
		sleep 1
		curl -X POST -d '{"cmd":"update.xmltv"}' http://$xTeveIP:$xTevePORT/api/
		sleep 1
		curl -X POST -d '{"cmd":"update.xepg"}' http://$xTeveIP:$xTevePORT/api/
		sleep 1
	fi
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
