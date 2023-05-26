FROM mongo:6.0.5

RUN apt-get update && apt-get -y install cron awscli

ENV CRON_TIME="0 3 * * *" \
  TZ=US/Eastern \
  CRON_TZ=US/Eastern

RUN touch /mongo_backup.log

ADD backup.sh /backup.sh
RUN chmod +x /backup.sh
RUN ln -s /backup.sh /usr/bin/backup

ADD restore.sh /restore.sh
RUN chmod +x /restore.sh
RUN ln -s /restore.sh /usr/bin/restore

ADD main.sh /main.sh
RUN chmod +x /main.sh
CMD /main.sh
