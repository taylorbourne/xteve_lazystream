# Lazystream Plex/Emby Bundle

This Docker provides a simple solution to get live NHL and MLB games into your Emby or Plex live TV setup. When combined with a comprehensive IPTV package this setup can you rolling with live TV and high quality sports. If you would only like to use this for the available sports, simply disable guide2go (or any other function you would like) from the cronjob.

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

# Setup

Please note that this Docker is configured to run in host mode. Once the Docker has started, check the configuration folder to complete the setup process. You'll want to edit `config/cronjob.sh` to suit your needs. Read this complete document before starting up the container.

## Sample volume mapping

| Container Path | Host Path                           |
| -------------- | ----------------------------------- |
| /root/.xteve   | /mnt/user/appdata/xteve/            |
| /config        | /mnt/user/appdata/xteve/\_config/   |
| /guide2go      | /mnt/user/appdata/xteve/\_guide2go/ |
| /tmp/xteve     | /tmp/xteve/                         |

## Hosts file

In order to properly play streams from Lazystream you must update your hosts file. Please follow the steps on this page: https://www.reddit.com/r/LazyMan/wiki/hostsfile

## guide2go

If you have an existing guide2go setup you may copy the `.json` files into the path mounted at `/guide2go`. Otherwise run the following command and follow the on-screen steps  
`docker exec -it dockername guide2go -configure /guide2go/your_epg_name.json`

## Testing cronjob function

Simply run the cronjob file inside the Docker container  
`docker exec -it dockername ./config/cronjob.sh`

# Credits

[Lazystream](https://github.com/tarkah/lazystream) – [@tarkah](https://github.com/tarkah/)  
[xTeVe](https://github.com/xteve-project/xTeVe) and [guide2go](https://github.com/mar-mei/guide2go) – [@marmei](https://github.com/mar-mei)  
Original author of the [xTeVe/guide2go Docker](https://github.com/alturismo/xteve_guide2goe) – [@alturismo](https://github.com/alturismo)
