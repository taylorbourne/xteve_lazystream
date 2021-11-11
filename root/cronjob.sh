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

	if [ "$trim_xmltv" = "yes" ]; then args+=("--trim"); fi
	if [ ! -z ${quality} ]; then args+=("--quality" "$quality"); fi
	if [ "$cdn" = "l3c" ]; then args+=("--cdn" "l3c"); fi
	if [ ! -z "$hostOverride" ]; then args+=("--host" "$hostOverride"); fi

	if [ "$include_nhl" = "yes" ]; then
		echo "Running Lazystream (NHL $quality via $cdn)..."
		mkdir -p /playlists/lazystream

		nhl_args=()

		nhl_args+=("--channel-prefix")
		nhl_args+=("Lazystream: NHL")
		nhl_args+=("--start-channel")
		nhl_args+=("1000")
		nhl_args+=("/playlists/lazystream/lazystream-nhl")

		if [ "$nhl_exclude_home" = "yes" ]; 	 then nhl_args+=("--exclude-feeds" "HOME"); fi
		if [ "$nhl_exclude_away" = "yes" ]; 	 then nhl_args+=("--exclude-feeds" "AWAY"); fi
		if [ "$nhl_exclude_national" = "yes" ];  then nhl_args+=("--exclude-feeds" "NATIONAL"); fi
		if [ "$nhl_exclude_french" = "yes" ]; 	 then nhl_args+=("--exclude-feeds" "FRENCH"); fi
		if [ "$nhl_exclude_composite" = "yes" ]; then nhl_args+=("--exclude-feeds" "COMPOSITE"); fi

		set -x
	    currenttime=$(date +%H:%M)
		if [[ "$currenttime" > "10:00" ]] && [[ "$currenttime" < "23:59" ]]; then
			echo "Running Lazystream today"
     		lazystream generate xmltv "${args[@]}" "${nhl_args[@]}"
   		else
		   	echo "Running Lazystream yesterday"
		   	yesterday=$(date --date '-1 day' +'%Y%m%d')
     		lazystream --date "$yesterday" generate xmltv "${args[@]}" "${nhl_args[@]}"
   		fi
		set +x
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

		if [ "$mlb_exclude_home" = "yes" ]; 	 then mlb_args+=("--exclude-feeds" "HOME"); fi
		if [ "$mlb_exclude_away" = "yes" ]; 	 then mlb_args+=("--exclude-feeds" "AWAY"); fi
		if [ "$mlb_exclude_national" = "yes" ];  then mlb_args+=("--exclude-feeds" "NATIONAL"); fi
		if [ "$mlb_exclude_composite" = "yes" ]; then mlb_args+=("--exclude-feeds" "COMPOSITE"); fi

		set -x
		lazystream generate xmltv "${args[@]}" "${mlb_args[@]}"
		set +x
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
	
	if [ -n "$main_xteve" ]; then
	echo "Updating Main xTeVe... $main_xteve"
	echo "Wating 30s before updating"
	sleep 30
	curl -s -X POST -d '{"cmd":"update.m3u"}' http://$main_xteve/api/
	sleep 1
	curl -s -X POST -d '{"cmd":"update.xmltv"}' http://$main_xteve/api/
	sleep 1
	curl -s -X POST -d '{"cmd":"update.xepg"}' http://$main_xteve/api/
	sleep 1
	fi

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
	if [ -z "$plexUpdateURL" ]; then
		echo "no Plex credentials provided"
	else
		curl -s -X POST "$plexUpdateURL"
		sleep 1
	fi
fi

# update Channels via API
if [ "$use_channelsAPI" = "yes" ]; then
	echo "Updating Channels..."
	if [ -z "$channelsUpdateM3uURL" ]; then
		echo "no Channels M3U URL provided"
	else
		curl -s -X POST "$channelsUpdateM3uURL"
		sleep 1
	fi
	if [ -z "$channelsUpdateXmltvURL" ]; then
		echo "no Channels XMLTV URL provided"
	else
		curl -s -X PUT "$channelsUpdateXmltvURL"
		sleep 1
	fi
fi

exit
