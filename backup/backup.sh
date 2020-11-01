#!/bin/bash
echo "Moving to Nextcloud directory"

# Change to Nextcloud docker-compose.yml directory
cd /nextcloud/docker-compose/yml/location

# Print Nextcloud stop message
echo "Stopping Nextcloud"

# Stop Redis and Nextcloud
docker-compose stop nextcloud && docker-compose stop redis

# Backup PostgreSQL database.
echo "Backing up Nextcloud database"
now=$(date +"%m_%d_%Y")
docker exec -i container_name pg_dump -U username database_name > /nextcloud/backup/directory/nextcloud-db_$now.sql

# Print backup status message
echo "Database backup finished with status $?"
date
echo

# I'm using linuxserver.io's Nextcloud container with ``/data`` and ``/config`` persistent volumes.
# Adjust these directories to meet your needs.
# Nextcloud folders to backup:
backup_files="/location/of/docker/nextcloud/data"
backup_files_2="/location/of/docker/nextcloud/appdata"
# Backup destination (adjust as needed):
dest="/location/of/backups/nextcloud"

# Backup file name:
now=$(date +"%m_%d_%Y")
# hostname=$(hostname -s)
archive_file="nextcloud-$now.tar.bz2"

# Print start message:
echo "Backing up $backup_files to $dest/$archive_file"

# Backup files using tar
tar cjf $dest/$archive_file $backup_files $backup_files_2

# Print end message:
echo "Backup finished with status $?"
date
echo

# Print file delete start message
echo "Deleting old backups"

# Delete backup files older than 1 day
find /location/of/backups/nextcloud/nextcloud-*.tar.bz2 -maxdepth 1 -type f -mtime 1 -delete && find /location/of/backups/nextcloud/nextcloud-db_*.sql -maxdepth 1 -type f -mtime 1 -delete

# Print file delete end message
echo "Deletion finished with status $?"
date
echo

# Print Nextcloud restart message
echo "Restarting Nextcloud"

# Restart Nextcloud
docker-compose up -d

# Long listing of files in destination folder to check file size
ls -lh $dest