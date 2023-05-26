#!/bin/bash
echo "Configure AWS credentials"
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_REGION"
echo "Configure AWS credentials completed"

# Export AWS Credentials into env file for cron job
printenv | sed 's/^\([a-zA-Z0-9_]*\)=\(.*\)$/export \1="\2"/g' >/root/project_env.sh

if [ -n "${INIT_BACKUP}" ]; then
    echo "Create a backup on the startup"
    if /backup.sh; then
        echo ""
    else
        echo ""
    fi
fi

if [ -n "${INIT_RESTORE}" ]; then
    echo "Restore store from lastest backup on startup"
    /restore.sh
fi

if [ -z "${DISABLE_CRON}" ]; then
    echo "${CRON_TIME} . /root/project_env.sh; /backup.sh >> /mongo_backup.log 2>&1" >/crontab.conf
    crontab /crontab.conf
    echo "Running cron job"
    cron && tail -f /mongo_backup.log
fi
