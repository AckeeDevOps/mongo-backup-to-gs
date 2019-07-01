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
  MONGO_PORT_CON=":${MONGO_PORT}"
fi

MONGO_OPLOG=""
if [ ! -z "$MONGO_DUMP_OPLOG" ]; then
  MONGO_OPLOG="--oplog"
fi

# verify gs config - ls bucket
$backup_tool ls "gs://${GS_URL%%/*}" > /dev/null
echo "Google storage bucket access verified."

mkdir -p /tmp/backup/
rm -rf -- /tmp/backup/* 
mongodump -h "$MONGO_URL" -u "$MONGO_USER" -p "$MONGO_PASSWORD" --out /tmp/backup/dump --gzip $MONGO_OPLOG
$backup_tool $backup_options /tmp/backup/ gs://$GS_URL/ 
