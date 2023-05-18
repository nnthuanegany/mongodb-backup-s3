#!/bin/bash
# Export AWS Credentials into env file for cron job
printenv | sed 's/^\([a-zA-Z0-9_]*\)=\(.*\)$/export \1="\2"/g' | grep -E "^export AWS" > /root/project_env.sh

echo "=> Configure S3 path started"
S3PATH="s3://$BUCKET/$BACKUP_FOLDER"
echo "  > $S3PATH"

echo "=> Configure AWS credentials"
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_REGION"
echo "=> Configure AWS credentials completed"

echo "=> Creating backup script"
rm -f /backup.sh
cat <<EOF >>/backup.sh
#!/bin/bash
backup() {
    BACKUP_FILE="$(date +%Y%m%d_%H%M%S)"
    S3BACKUP=${S3PATH}/\${BACKUP_FILE}
    S3LATEST=${S3PATH}/latest.gz
    echo "=> Backup started"
    echo "=> Dump started"
    mongodump --uri="$MONGO_HOST" --username="$MONGO_USERNAME" --password="$MONGO_PASSWORD" --authenticationDatabase=admin --db="$MONGO_DATABASE" --out="dump/\$BACKUP_FILE"
    echo "----> Dump succeeded"
    echo "Compress the backup directory into a gz file started"
    tar -czvf "dump/\$BACKUP_FILE.gz" "dump/\$BACKUP_FILE"
    echo "----> Compress the backup directory into a gz file completed"
    echo "=> Upload to s3 started"
    aws s3 cp "dump/\$BACKUP_FILE.gz" "\$S3BACKUP.gz"
    aws s3 cp "dump/\$BACKUP_FILE.gz" "\$S3LATEST"
    echo "----> Upload to s3 succeeded"
    echo "----> Backup completed"
}
backup || echo "Backup failed"
EOF
chmod +x /backup.sh
echo "=> Backup script created"

# echo "=> Creating restore script"
# rm -f /restore.sh
# cat <<EOF >>/restore.sh
# #!/bin/bash
# if [[( -n "\${1}" )]];then
#     RESTORE_ME=\${1}.dump.gz
# else
#     RESTORE_ME=latest.dump.gz
# fi
# S3RESTORE=${S3PATH}\${RESTORE_ME}
# echo "=> Restore database from \${RESTORE_ME}"
# if aws s3 cp \${S3RESTORE} \${RESTORE_ME} && mongorestore --host ${MONGODB_HOST} --port ${MONGODB_PORT} ${USER_STR}${PASS_STR}${DB_STR} --drop ${EXTRA_OPTS} --archive=\${RESTORE_ME} --gzip && rm \${RESTORE_ME}; then
#     echo "   Restore succeeded"
# else
#     echo "   Restore failed"
# fi
# echo "=> Done"
# EOF
# chmod +x /restore.sh
# echo "=> Restore script created"

# echo "=> Creating list script"
# rm -f /listbackups.sh
# cat <<EOF >>/listbackups.sh
# #!/bin/bash
# aws s3 ls ${S3PATH}
# EOF
# chmod +x /listbackups.sh
# echo "=> List script created"

# ln -s /restore.sh /usr/bin/restore
ln -s /backup.sh /usr/bin/backup
ln -s /listbackups.sh /usr/bin/listbackups

touch /mongo_backup.log

if [ -n "${INIT_BACKUP}" ]; then
    echo "=> Create a backup on the startup"
    /backup.sh
fi

# if [ -n "${INIT_RESTORE}" ]; then
#     echo "=> Restore store from lastest backup on startup"
#     /restore.sh
# fi

if [ -z "${DISABLE_CRON}" ]; then
    echo "${CRON_TIME} . /root/project_env.sh; /backup.sh >> /mongo_backup.log 2>&1" >/crontab.conf
    crontab /crontab.conf
    echo "=> Running cron job"
    cron && tail -f /mongo_backup.log
fi
