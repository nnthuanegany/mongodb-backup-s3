#!/bin/bash

echo "Restore database from ${RESTORE_NAME} started"

download() {
    echo "  Download ${RESTORE_NAME}.gz from s3 started"
    aws s3 cp "s3://${BUCKET}/${BACKUP_FOLDER}/${RESTORE_NAME}.gz" /dump/
    echo "  Download ${RESTORE_NAME}.gz from s3 succeeded"
}

if download; then
    echo "  Download succeeded"
else
    echo "  Download failed"
    exit 1
fi

extract() {
    echo "  Extract ${RESTORE_NAME}.gz to ${RESTORE_ME} started"
    mkdir /dump/${RESTORE_NAME}
    tar -zxf /dump/${RESTORE_NAME}.gz -C /dump/${RESTORE_NAME}
    echo "  Extract ${RESTORE_NAME}.gz succeeded"
}

if extract; then
    echo "  Extract succeeded"
else
    echo "  Extract failed"
    exit 2
fi

restore() {
    echo "  Restore database started"
    mongorestore \
        --uri="$MONGO_HOST" \
        --username="$MONGO_USERNAME" \
        --password="$MONGO_PASSWORD" \
        --authenticationDatabase=admin \
        --nsInclude="$MONGO_DATABASE" \
        --db="$MONGO_DATABASE" \
        --drop /dump/$RESTORE_NAME
}

if restore; then
    echo "  Restore database succeeded"
else
    echo "  Restore database faield"
    exit 3
fi

clean() {
    echo "  Clean started"
    rm /dump/${RESTORE_NAME}.gz
    rm -r /dump/${RESTORE_NAME}
}

if clean; then
    echo "  Clean succeeded"
else
    echo "  Clean failed"
    exit 4
fi

echo "Restore databse from ${RESTORE_NAME} from s3 completed"
