# Backup container for mongo instances to Google Storage

This image provides a cron daemon that runs daily backups from mongo (clustered or single instance) to Google Storage.

Following ENV variables must be specified:
 - `MONGO_URL` contains the connection string for mongodump command line client (option `-h`)
 - `MONGO_USER` contains the username
 - `MONGO_PASSWORD` password of a user who has access to all dbs
 - `MONGO_DUMP_OPLOG` - if set to any value, adds `--oplog` parameter 
 - `GS_URL` contains address in GS where to store backups, without the `gs://` prefix
  - `bucket-name/directory`
 - `CRON_SCHEDULE` cron schedule string, default '0 2 * * *'


