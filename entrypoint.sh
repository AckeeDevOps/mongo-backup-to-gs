#!/bin/bash
set -eo pipefail

backup_tool="gsutil"
backup_options="rsync -r"

# verify variables
if [ -z "$GS_ACCESS_KEY" -o -z "$GS_SECRET_KEY" -o -z "$GS_URL" -o -z "$MONGO_URL" -o -z "$MONGO_USER" -o -z "$MONGO_PASSWORD" ]; then
	echo >&2 'Backup information is not complete. You need to specify GS_ACCESS_KEY, GS_SECRET_KEY, GS_URL, MONGO_URL, MONGO_USER, MONGO_PASSWORD. No backups, no fun.'
	exit 1
fi

# set gs config
echo -e "[Credentials]\ngs_access_key_id = $GS_ACCESS_KEY\ngs_secret_access_key = $GS_SECRET_KEY" > /root/.boto

# verify GS config
$backup_tool ls "gs://$GS_URL" > /dev/null

# set cron schedule TODO: check if the string is valid (five or six values separated by white space)
[[ -z "$CRON_SCHEDULE" ]] && CRON_SCHEDULE='0 2 * * *' && \
   echo "CRON_SCHEDULE set to default ('$CRON_SCHEDULE')"

# add a cron job
echo "$CRON_SCHEDULE root rm -rf /tmp/dump && mongodump -h '$MONGO_URL' -u '$MONGO_USER' -p '$MONGO_PASSWORD' --out /tmp/dump/ --gzip >> /var/log/cron.log 2>&1 && $backup_tool $backup_options /tmp/dump gs://$GS_URL/ >> /var/log/cron.log 2>&1 && rm -rf /tmp/dump" >> /etc/crontab
crontab /etc/crontab

exec "$@"
