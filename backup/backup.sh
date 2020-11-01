# original source: https://old.reddit.com/r/NextCloud/comments/gvu8m3/nextcloud_docker_backup/

#!/bin/bash -e
echo "Moving to Nextcloud directory"

########## Start user configurable variables #########
# Adjust these variables to fit your needs

# docker-compose.yml directory
dcd="/nextcloud/docker-compose/yml/location"

# I'm using linuxserver.io's Nextcloud container with ``/data`` and ``/config``
# persistent volumes. Nextcloud folders to backup:
backup_files="/location/of/docker/nextcloud/data"
backup_files_2="/location/of/docker/nextcloud/appdata"

# Backup destination (adjust as needed):
dest="/location/of/backups/nextcloud"

# Backup file name date format
now=$(date +"%m_%d_%Y")

# Database backup file name
db_backup="nextcloud-db_$now.sql"

# Nextcloud backup file name
nx_backup="nextcloud_$now.tar.bz2"
######### End user configurable variables #########

# Change to Nextcloud docker-compose.yml directory
cd $dcd

# Print Nextcloud stop message
echo "Stopping Nextcloud"

# Stop Redis and Nextcloud
docker-compose stop nextcloud && docker-compose stop redis

# Backup PostgreSQL database
echo "Backing up Nextcloud database"
docker exec -i container_name pg_dump -U username database_name > $dest/$db_backup

# Print backup status message
echo "Database backup finished with status $?"
date
echo

# Print start message:
echo "Backing up Nextcloud data"

# Backup files using tar
tar cjf $dest/$nx_backup $backup_files $backup_files_2

# Print end message:
echo "Backup finished with status $?"
date
echo

# Print file delete start message
echo "Deleting old backups"

# Delete backup files older than 1 day
find $dest/nextcloud_*.tar.bz2 -maxdepth 1 -type f -mtime 1 -delete && find $dest/nextcloud-db_*.sql -maxdepth 1 -type f -mtime 1 -delete

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