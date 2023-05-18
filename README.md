# mongodb-backup-s3

This image runs mongodump to backup data using cronjob to an s3 bucket

## Parameters

`AWS_ACCESS_KEY_ID` - your aws access key id (for your s3 bucket)

`AWS_SECRET_ACCESS_KEY`: - your aws secret access key (for your s3 bucket)

`AWS_REGION`: - your aws region

`BUCKET`: - your s3 bucket

`BACKUP_FOLDER`: - name of folder or path to put backups (eg `myapp/db_backups/`). defaults to root of bucket.

`MONGODB_HOST` - the host/ip of your mongodb database (eg `mongodb://localhost:27017`)

`MONGODB_USERNAME` - the username of your mongodb database. If MONGODB_USERNAME is empty while MONGODB_PASS is not, the image will use admin as the default username

`MONGO_PASSWORD` - the password of your mongodb database

`MONGO_DATABASE` - the database name to dump. If not specified, it will dump all the databases

`EXTRA_OPTS` - any extra options to pass to mongodump command

`CRON_TIME` - the interval of cron job to run mongodump. `0 3 * * *` by default, which is every day at 03:00hrs.

`TZ` - timezone. default: `US/Eastern`

`CRON_TZ` - cron timezone. default: `US/Eastern`

`INIT_BACKUP` - if set, create a backup when the container launched

`INIT_RESTORE` - if set, restore from latest when container is launched

`DISABLE_CRON` - if set, it will skip setting up automated backups. good for when you want to use this container to seed a dev environment.

## Restore from a backup

To see the list of backups, you can run:

```bash
docker exec mongodb-backup-s3 /listbackups.sh
```

To restore database from a certain backup, simply run (pass in just the timestamp part of the filename):

```bash
docker exec mongodb-backup-s3 /restore.sh 20170406T155812
```

To restore latest just:

```bash
docker exec mongodb-backup-s3 /restore.sh
```

## Acknowledgements

- forked from [futurist](https://github.com/futurist)'s fork of [tutumcloud/mongodb-backup](https://github.com/tutumcloud/mongodb-backup)
