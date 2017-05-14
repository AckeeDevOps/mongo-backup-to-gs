#!/bin/bash
backup_tool="gsutil"
backup_options="-m rsync -r"

mkdir -p /tmp/backup/
rm -rf /tmp/backup/*
mongodump -h '$MONGO_URL' -u '$MONGO_USER' -p '$MONGO_PASSWORD' --out /tmp/backup/
find /tmp/backup -type f -exec gzip --fast {} \;
find /tmp/backup -type f -size +4G -exec split -b 4G {} {}.part- \;
find /tmp/backup -type f -name '*.gz' -size +4G -exec rm {} \;
$backup_tool $backup_options /tmp/backup/ gs://$GS_URL/
