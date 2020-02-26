#!/bin/bash

##### Config
use_xTeveAPI="yes"
use_embyAPI="no"
use_plexAPI="no"
use_TVH_Play="no"
use_TVH_move="no"

### List of created lineup json files in /guide2go
# sample with 3 jsons lineups, adjust to yours
JsonList="CBLguide.json SATguide.json SATSport.json"

### to create your lineups do as follows and follow the instructions
# docker exec -it <yourdockername> guide2go -configure /guide2go/<lineupnamehere>.json

### xTeve ip, Port in case API is used to update XEPG
xTeveIP="192.168.1.2"
xTevePORT="34400"

### Generate playlist and xml data from lazystream
lazystream generate xmltv /playlist/lazystream

### Emby ip, Port, apiKey, update ID in case API is used to update EPG directly after guide2go
# ONLY when xteve API is in use, otherwise obsolete
# API Key, https://github.com/MediaBrowser/Emby/wiki/Api-Key-Authentication
# embyID, settings, scroll down click API, Scheduled Task Service, GET /ScheduledTasks, Try, Execute, look for "Refresh Guide" ID, sample here 9492d30c70f7f1bec3757c9d0a4feb45
embyIP="192.168.1.2"
embyPORT="8096"
embyApiKey=""
embyID="9492d30c70f7f1bec3757c9d0a4feb45"

### Plex ip, Port, Token, TV Section ID in case API is used to update EPG directly after guide2go
# ONLY when xteve API is in use, otherwise obsolete
# Plex Token, https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/
# plexID, http://YOUR_IP_HERE:32400/?X-Plex-Token=YOUR_TOKEN_HERE , look for "tv.plex.providers.epg.xmltv:  ", sample here 11
plexIP="192.168.1.2"
plexPORT="32400"
plexToken=""
plexID="11"

### TVHeadend ip, Port in case m3u Playlist is wanted
TVHIP="192.168.1.2"
TVHPORT="9981"
TVHUSER="username"
TVHPASS="password"
TVHOUT="/root/.xteve/data/channels.m3u"

### Copy a final xml (sample xteve) to tvheadend Data ### u have to mount TVHPATH data dir
TVHSOURCE="/root/.xteve/data/xteve.xml"
TVHPATH="/TVH"

# cronjob, check sample_cron.txt with an editor to adjust time

### END Config
##
#

# run guide2go in loop
if [ "$use_guide2go" = "yes" ]; then
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

# get TVH playlist
if [ "$use_TVH_Play" = "yes" ]; then
	if [ -z "$TVHIP" ]; then
		echo "no TVHeadend credentials"
	else
		if [ -z "$TVHUSER" ]; then
			wget -O $TVHOUT http://$TVHIP:$TVHPORT/playlist
		else
			wget -O $TVHOUT http://$TVHUSER:$TVHPASS@$TVHIP:$TVHPORT/playlist
		fi
	fi
fi

sleep 1

# update xteve via API
if [ "$use_xTeveAPI" = "yes" ]; then
	if [ -z "$xTeveIP" ]; then
		echo "no xTeve credentials"
	else
		curl -X POST -d '{"cmd":"update.xmltv"}' http://$xTeveIP:$xTevePORT/api/
		sleep 1
		curl -X POST -d '{"cmd":"update.xepg"}' http://$xTeveIP:$xTevePORT/api/
		sleep 1
	fi
fi

# copy file to TVHeadend
if [ "$use_TVH_move" = "yes" ]; then
	if [ -z "$TVHPATH" ]; then
		echo "no Path credential"
	else
		cp $TVHSOURCE $TVHPATH/guide.xml
	fi
fi

# update Emby via API
if [ "$use_embyAPI" = "yes" ]; then
	if [ -z "$embyIP" ]; then
		echo "no Emby credentials"
	else
		curl -X POST "http://$embyIP:$embyPORT/emby/ScheduledTasks/Running/$embyID?api_key=$embyApiKey" -H "accept: */*" -d ""
		sleep 1
	fi
fi

# update Plex via API
if [ "$use_plexAPI" = "yes" ]; then
	if [ -z "$plexIP" ]; then
		echo "no Plex credentials"
	else
		curl -s "http://$plexIP:$plexPORT/livetv/dvrs/$plexID/reloadGuide?X-Plex-Product=Plex%20Web&X-Plex-Version=4.8.4&X-Plex-Client-Identifier=$plexToken&X-Plex-Platform=Firefox&X-Plex-Platform-Version=69.0&X-Plex-Sync-Version=2&X-Plex-Features=external-media&X-Plex-Model=bundled&X-Plex-Device=Linux&X-Plex-Device-Name=Firefox&X-Plex-Device-Screen-Resolution=1128x657%2C1128x752&X-Plex-Language=de" -H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:69.0) Gecko/20100101 Firefox/69.0" -H "Accept: text/plain, */*; q=0.01" -H "Accept-Language: de" --compressed -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" -H "Referer: http://$plexIP:$plexPORT/web/index.html" --data ""
		sleep 1
	fi
fi

exit