#!/bin/bash

crond -l 2

CRONJOB_FILE=/config/cronjob.sh

if [ -f "$CRONJOB_FILE" ]; then
	echo "$CRONJOB_FILE exist"
	chmod +x $CRONJOB_FILE
	chmod 777 $CRONJOB_FILE
else 
	echo "$CRONJOB_FILE does not exist"
	cp /cronjob.sh $CRONJOB_FILE
	chmod +x $CRONJOB_FILE
	chmod 777 $CRONJOB_FILE
fi

CRON_FILE=/config/cron.txt

if [ -f "$CRON_FILE" ]; then
	. $CRON_FILE
else
	printf '0  0  *  *  *  /config/cronjob.sh' > /etc/crontabs/root
	cp /sample_cron.txt /config/sample_cron.txt
fi

XTEVE_FILE=/config/xteve.txt

if [ -f "$XTEVE_FILE" ]; then
	. $XTEVE_FILE
else
	cp /sample_xteve.txt /config/sample_xteve.txt
	xteve -port=34400 -config=/root/.xteve/
fi

exit