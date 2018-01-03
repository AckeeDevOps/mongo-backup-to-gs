#!/bin/bash
set -eo pipefail

backup_tool="/google-cloud-sdk/bin/gsutil"
backup_options="-m rsync -r"

# verify variables
if [ -z "$GS_URL" -o -z "$MONGO_URL" ]; then
	echo >&2 'Backup information is not complete. You need to specify GS_URL, MONGO_URL. No backups, no fun.'
	exit 1
fi

# set mongo user in connection string
MONGO_USER_CON=""
if [ ! -z "$MONGO_USER" ]; then
  MONGO_USER_CON="-u $MONGO_USER"
fi

# set mongo password in connection string
MONGO_PASS_CON=""
if [ ! -z "$MONGO_PASSWORD" ]; then
  MONGO_PASS_CON="-p$MONGO_PASSWORD"
fi

# set default mongo port, if it's not set
MONGO_PORT_CON=""
if [ ! -z "$MONGO_PORT" ]; then
  MONGO_PORT_CON=":27017"
fi

# verify mongo connection
mongo "${MONGO_URL}${MONGO_PORT_CON}/admin" $MONGO_USER_CON $MONGO_PASS_CON --eval "db.stats()" >> /dev/null
echo "DB connection verified."

# verify gs config - ls bucket
$backup_tool ls "gs://${GS_URL%%/*}" > /dev/null
echo "Google storage bucket access verified."

# set cron schedule TODO: check if the string is valid (five or six values separated by white space)
[[ -z "$CRON_SCHEDULE" ]] && CRON_SCHEDULE='0 2 * * *' && \
   echo "CRON_SCHEDULE set to default ('$CRON_SCHEDULE')"

echo "$CRON_SCHEDULE root mkdir -p /tmp/backup/ ; rm -rf /tmp/backup/* && mongodump -h '$MONGO_URL' --out /tmp/backup/ >> /var/log/cron.log 2>&1 && find /tmp/backup -type f ! -name '*.gz' -exec gzip --fast {} >> /var/log/cron.log 2>&1 \;  && find /tmp/backup -type f -size +4G -exec split -b 4G {} {}.part- >> /var/log/cron.log 2>&1 \;  && find /tmp/backup -type f -name '*.gz' -size +4G -exec rm {} >> /var/log/cron.log 2>&1 \;  && $backup_tool $backup_options /tmp/backup/ gs://$GS_URL/ >> /var/log/cron.log 2>&1" >> /etc/crontab

exec "$@"
