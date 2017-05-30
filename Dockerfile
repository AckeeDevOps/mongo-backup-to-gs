FROM mongo:latest

# backups to Google Storage
RUN apt-get update && apt-get install -y python python-pip cron && easy_install -U pip && pip2 install gsutil && rm -rf /var/lib/apt/lists/*
# gcsfuse mount GS Bucket locally -- RUN CONTAINER IN PRIVILEGED MODE!!!
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget autofs \
  && echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" | tee /etc/apt/sources.list.d/google-cloud.sdk.list \
  && echo "deb http://packages.cloud.google.com/apt gcsfuse-xenial main" | tee /etc/apt/sources.list.d/gcsfuse.list \
  && wget -qO- https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get update && apt-get install -y --no-install-recommends google-cloud-sdk gcsfuse \
  && mkdir -p /etc/autofs && touch /etc/autofs/auto.gcsfuse && rm -rf /var/lib/apt/lists
  
# entrypoint
COPY entrypoint.sh /entrypoint.sh
ADD crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab

ENTRYPOINT ["/entrypoint.sh"]

CMD touch /var/log/cron.log && cron && tail -f /var/log/cron.log
