#!/bin/bash

crond -l 2


# Update certs
rm /root/.gnutls/known_hosts
printf 'y\n' | gnutls-cli --tofu playback.svcs.mlb.com:443
printf 'y\n' | gnutls-cli --tofu mf.svc.nhl.com:443
printf 'y\n' | gnutls-cli --tofu mlb-ws-mf.media.mlb.com:443
cat /root/.gnutls/known_hosts

CRONJOB_FILE=/config/cronjob.sh

if [ -f "$CRONJOB_FILE" ]; then
	echo "$CRONJOB_FILE already exists – if changes are necessary please edit this file."
	chmod +x $CRONJOB_FILE
	chmod 777 $CRONJOB_FILE
else 
	echo "$CRONJOB_FILE does not exist, auto-generating cronjob file. Please edit to complete setup."
	cp /cronjob.sh $CRONJOB_FILE
	chmod +x $CRONJOB_FILE
	chmod 777 $CRONJOB_FILE
fi

CRON_FILE=/config/cron.txt

if [ -f "$CRON_FILE" ]; then
	. $CRON_FILE
else
	echo "No cron definition found..."
	echo "By default, cronjob will run every night at midnight unless cron file is configured."
	printf '0  0  *  *  *  /config/cronjob.sh' > /etc/crontabs/root
	cp /sample_cron.txt /config/sample_cron.txt
fi

XTEVE_FILE=/config/xteve.txt

echo "Starting xTeVe..."
if [ -f "$XTEVE_FILE" ]; then
	. $XTEVE_FILE
else
	echo "Starting xTeVe with default config..."
	cp /sample_xteve.txt /config/sample_xteve.txt
	xteve -port=34400 -config=/root/.xteve/
fi

exit
