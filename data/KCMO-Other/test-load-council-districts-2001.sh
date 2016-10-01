#!/bin/sh
#
# Expected to be called by cron
# 55 3 * * * /var/wwwsites/dev-api.codeforkc.org/data/KCMO-Other/load  | mail -s "KCMO-land-bank-parcels" paulb@savagesoft.com 
TEMP_FILE_NAME=/tmp/Other.gdb

SCRIPT_PATH=`dirname $0`
#
# Grab and put the data into a temp file
#


cd $SCRIPT_PATH

sh load-council-districts-2001.sh


