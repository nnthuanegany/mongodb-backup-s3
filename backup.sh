#!/bin/bash

S3PATH="s3://$BUCKET/$BACKUP_FOLDER"
BACKUP_NAME="$(date +%Y%m%d_%H%M%S)"
S3BACKUP=${S3PATH}/${BACKUP_NAME}
S3LATEST=${S3PATH}/latest.gz

dump() {
    echo "  Dump started"
    mongodump \
        --uri="$MONGO_HOST" \
        --username="$MONGO_USERNAME" \
        --password="$MONGO_PASSWORD" \
        --authenticationDatabase=admin \
        --db="$MONGO_DATABASE" \
        --out="dump/$BACKUP_NAME"
}

echo "Backup started"
if dump; then
    echo "  Dump succeeded"
else
    echo "  Dump failed"
    exit 1
fi

compress() {
    echo "  Compress the backup directory into a gz file started"
    tar -C "dump/$BACKUP_NAME/$MONGO_DATABASE" -czvf "dump/$BACKUP_NAME.gz" .
}

if compress; then
    echo "  Compress the backup directory into a gz file succeeded"
else
    echo "  Compress the backup directory into a gz file failed"
    exit 2
fi

upload_to_s3() {
    echo "  Upload to s3 started"
    aws s3 cp "dump/$BACKUP_NAME.gz" "$S3BACKUP.gz"
    aws s3 cp "dump/$BACKUP_NAME.gz" "$S3LATEST"
}

if upload_to_s3; then
    echo "  Upload to s3 succeeded"
else
    echo "  Upload to s3 failed"
    exit 3
fi

echo "Backup completed"
