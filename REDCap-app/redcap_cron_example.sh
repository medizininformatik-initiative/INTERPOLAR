#!/bin/sh

# This is an example shell script calling REDCap cron job(s).
# You may modify it according to your setup.

CONTAINERID=$(docker ps -q -f name=interpolar-redcap-1 -f ancestor=interpolar-redcap) 

if [ "$CONTAINERID" != "" ]; then
   docker exec $CONTAINERID /usr/local/bin/php /var/www/html/redcap/cron.php > /dev/null
fi
