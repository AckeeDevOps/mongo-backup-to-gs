FROM mongo:latest

# backups to Google Storage
RUN apt-get update && apt-get install -y python python-pip cron && easy_install -U pip && pip2 install gsutil && rm -rf /var/lib/apt/lists/*

# entrypoint
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD touch /var/log/cron.log && cron && tail -f /var/log/cron.log
