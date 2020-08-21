#!/usr/bin/with-contenv bash

function prepend() {
	time=`date +"%Y/%m/%d %H:%M:%S"`
	while read line;
	do echo "${time} ${1}${line}";
	done;
}

exec 1> >(prepend "[cronjob.sh] ")

echo "Running scripts..."

### Generate playlist and XML data from Lazystream
if [ "$use_lazystream" = "yes" ]; then

	args=()
	if [ ! -z ${quality} ]; then args+=("--quality" "$quality"); fi
	if [ "$cdn" = "l3c" ]; then args+=("--cdn" "l3c"); fi

	if [ "$include_nhl" = "yes" ]; then
		echo "Running Lazystream (NHL $quality via $cdn)..."
		mkdir -p /playlists/lazystream

		nhl_args=()

		nhl_args+=("--channel-prefix")
		nhl_args+=("Lazystream: NHL")
		nhl_args+=("--start-channel")
		nhl_args+=("1000")
		nhl_args+=("/playlists/lazystream/lazystream-nhl")

		lazystream generate xmltv "${args[@]}" "${nhl_args[@]}"
	fi
	if [ "$include_mlb" = "yes" ]; then
		echo "Running Lazystream (MLB $quality via $cdn)..."
		mkdir -p /playlists/lazystream

		mlb_args=()

		mlb_args+=("--sport")
		mlb_args+=("mlb")
		mlb_args+=("--channel-prefix")
		mlb_args+=("Lazystream: MLB")
		mlb_args+=("--start-channel")
		mlb_args+=("2000")
		mlb_args+=("/playlists/lazystream/lazystream-mlb")

		lazystream generate xmltv "${args[@]}" "${mlb_args[@]}"
	fi
fi

# run guide2go in a loop
if [ "$use_guide2go" = "yes" ]; then
	echo "Running guide2Go..."
	for yamls in $YamlList
		do
		yamlfile="${yamls%.*}"
		filecache='  "file.cache": "/guide2go/cache_'$yamls'",'
		fileoutput='  "file.output": "/guide2go/'$yamlfile'.xml",'
		sed -i "/file.cache/c $filecache" /guide2go/$yamls
		sed -i "/file.output/c $fileoutput" /guide2go/$yamls
		guide2go -config /guide2go/$yamls
	done
fi

sleep 1

# update xteve via API
if [ "$use_xTeveAPI" = "yes" ]; then
	echo "Updating xTeVe..."
	curl -s -X POST -d '{"cmd":"update.m3u"}' http://127.0.0.1:$XTEVE_PORT/api/
	sleep 1
	curl -s -X POST -d '{"cmd":"update.xmltv"}' http://127.0.0.1:$XTEVE_PORT/api/
	sleep 1
	curl -s -X POST -d '{"cmd":"update.xepg"}' http://127.0.0.1:$XTEVE_PORT/api/
	sleep 1
fi

# update Emby via API
if [ "$use_embyAPI" = "yes" ]; then
	echo "Updating Emby..."
	if [ -z "$embyIP" ]; then
		echo "no Emby credentials provided"
	else
		curl -s -X POST "http://$embyIP:$embyPORT/emby/ScheduledTasks/Running/$embyID?api_key=$embyApiKey" -H "accept: */*" -d ""
		sleep 1
	fi
fi

# update Plex via API
if [ "$use_plexAPI" = "yes" ]; then
	echo "Updating Plex..."
	if [ -z "$plexIP" ]; then
		echo "no Plex credentials provided"
	else
		curl -s -X POST "http://$plexIP:$plexPORT/livetv/dvrs/$plexID/reloadGuide?X-Plex-Token=$plexToken"
		sleep 1
	fi
fi

exit
