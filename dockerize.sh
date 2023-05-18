#!/bin/bash
docker buildx build -t eganytech/egany:mongodb-backup-s3 .
docker push eganytech/egany:mongodb-backup-s3
