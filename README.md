# Lazystream/IPTV Media Server Bridgesss

This Docker provides a simple solution to get live NHL and MLB games into your Emby, Plex, or Channels live TV setup. When combined with a comprehensive IPTV package this setup can get you rolling with live TV and high quality sports. If you would only like to use this for the available sports, simply disable guide2go (or any other function you would like). Please see the Wiki for some user-created scripts to help get things setup.

- [Run](#run)
- [Setup](#setup)
  - [Env file](#env-file)
  - [Cron schedule](#cron-schedule)
  - [Sample volume mapping](#sample-volume-mapping)
  - [xTeVe](#xteve)
  - [guide2go](#guide2go)
  - [Testing cronjob function](#testing-cronjob-function)
  - [Notes on Channels DVR](#notes-on-channels-dvr)
- [Credits](#credits)
  - [guide2go](#guide2go-1)
  - [Lazystream](#lazystream)
  - [xTeVe](#xteve-1)

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

or see [docker-compose.yml](docker-compose.yml) for an example docker-compose setup.

# Setup

## Env file

Defaults & behavior can be changed through environment variables. `sample.env` should be renamed to `.env` and supplied through the `--env-file` docker run option. The `.env` file can also be picked up if using this in a `docker compose` setup.

## Cron schedule

By default, the cron job is scheduled to run every hour. A custom cron schedule can be specified by renaming the `sample_cron.txt` file in the `/config` volume to `cron.txt` and editing the schedule. Make sure to restart your container to take effect.

## Sample volume mapping

| Container Path | Host Path                         |
| -------------- | --------------------------------- |
| /xteve         | /mnt/user/appdata/xteve/.xteve    |
| /config        | /mnt/user/appdata/xteve/config    |
| /guide2go      | /mnt/user/appdata/xteve/guide2go  |
| /playlists     | /mnt/user/appdata/xteve/playlists |
| /tmp/xteve     | /tmp/xteve                        |

## xTeVe

By default, xTeVe is setup with all 200 channels mapped for NHL and MLB games. This can be setup directly with Plex / Emby to work out of the box without any changes. If needed, changes can be made to xTeVe by going to `127.0.0.1:34400/web/`.

## guide2go

If you have an existing guide2go setup you may copy the `.yaml` files into the path mounted at `/guide2go`. Otherwise run the following command and follow the on-screen steps  
`docker exec -it dockername guide2go -configure /guide2go/your_epg_name.yaml`

## Testing cronjob function

Simply run the cronjob file inside the Docker container  
`docker exec -it dockername ./cronjob.sh`

## Notes On Channels DVR

- You have to select MPEG-TS as the stream format
- The stream only works in a browser - not on Android TV or Android
- Adding an m3u playlist to Channels:
  https://getchannels.com/docs/channels-dvr-server/how-to/custom-channels/#adding-your-custom-channels

# Credits

[Lazystream](https://github.com/tarkah/lazystream) – [@tarkah](https://github.com/tarkah/)  
[xTeVe](https://github.com/xteve-project/xTeVe) and [guide2go](https://github.com/mar-mei/guide2go) – [@marmei](https://github.com/mar-mei)  
Original author of the [xTeVe/guide2go Docker](https://github.com/alturismo/xteve_guide2go) – [@alturismo](https://github.com/alturismo)

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
