# Lazystream Plex/Emby Bundle

This Docker provides a simple solution to get live NHL and MLB games into your Emby or Plex live TV setup. When combined with a comprehensive IPTV package this setup can get you rolling with live TV and high quality sports. If you would only like to use this for the available sports, simply disable guide2go (or any other function you would like).

- [Run](#run)
- [Setup](#setup)
	- [Env file](#env-file)
	- [Cron schedule](#cron-schedule)
	- [Sample volume mapping](#sample-volume-mapping)
	- [guide2go](#guide2go)
	- [Testing cronjob function](#testing-cronjob-function)
- [Credits](#credits)
	- [guide2go](#guide2go-1)
	- [Lazystream](#lazystream)
	- [xTeVe](#xteve)

# Run

```
docker run -d \
	--name=xteve_lazystream \
	-p 34400:34400 \
	-e TZ="America/Los_Angeles" \
	--env-file=.env \
	--log-opt max-size=10m \
	--log-opt max-file=3 \
	-v /mnt/user/appdata/xteve/.xteve:/xteve:rw \
	-v /mnt/user/appdata/xteve/config/:/config:rw \
	-v /mnt/user/appdata/xteve/guide2go/:/guide2go:rw \
	-v /mnt/user/appdata/xteve/playlists/:/playlists:rw \
	-v /tmp/xteve/:/tmp/xteve:rw \
	taylorbourne/xteve_lazystream
```

# Setup

## Env file

Defaults & behavior can be changed through environment variables. `sample.env` should be renamed to `.env` and supplied through the `--env-file` docker run option. The `.env` file can also be picked up if using this in a `docker compose` setup.

## Cron schedule

By default, the cron job is scheduled to run daily at 00:00. A custom cron schedule can be specified by renaming the `sample_cron.txt` file in the `/config` volume to `cron.txt` and editing the schedule. Make sure to restart your container to take effect.

## Sample volume mapping

| Container Path | Host Path                         |
| -------------- | --------------------------------- |
| /xteve         | /mnt/user/appdata/xteve/.xteve    |
| /config        | /mnt/user/appdata/xteve/config    |
| /guide2go      | /mnt/user/appdata/xteve/guide2go  |
| /playlists     | /mnt/user/appdata/xteve/playlists |
| /tmp/xteve     | /tmp/xteve                        |

## guide2go

If you have an existing guide2go setup you may copy the `.json` files into the path mounted at `/guide2go`. Otherwise run the following command and follow the on-screen steps  
`docker exec -it dockername guide2go -configure /guide2go/your_epg_name.json`

## Testing cronjob function

Simply run the cronjob file inside the Docker container  
`docker exec -it dockername ./cronjob.sh`

# Credits

[Lazystream](https://github.com/tarkah/lazystream) – [@tarkah](https://github.com/tarkah/)  
[xTeVe](https://github.com/xteve-project/xTeVe) and [guide2go](https://github.com/mar-mei/guide2go) – [@marmei](https://github.com/mar-mei)  
Original author of the [xTeVe/guide2go Docker](https://github.com/alturismo/xteve_guide2goe) – [@alturismo](https://github.com/alturismo)

## guide2go

XMLTV EPG grabber for Schedules Direct, thanks to @marmei  
GitHub: https://github.com/mar-mei/guide2go  
Schedules Direct: http://www.schedulesdirect.org/

## Lazystream

GitHub: https://github.com/tarkah/lazystream

## xTeVe

IPTV and EPG proxy server for Plex, Emby, etc – thanks to @marmei  
Website: http://xteve.de  
Discord: https://discordapp.com/channels/465222357754314767/465222357754314773