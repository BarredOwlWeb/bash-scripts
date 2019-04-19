#!/bin/bash
DATE=$(date +%Y%m%d)
TODAY=$(date +%a)
YESTERDAY=$(date --date="1 day ago" +%Y%m%d)

if [[ $TODAY == "Sun" ]]; then
	# Delete anything older than 35 days
	find -mindepth 1 -maxdepth 1 -type d -mtime +35 -exec rm -rf {} \;

	# Delete any other directories that are older than 2 days, that do not contain "SUN" in the dir name
        find -mindepth 1 -maxdepth 1 -type d -mtime +2 ! \( -name "*SUN*" \) -exec rm -rf {} \;

	# Set $DIR_NAME and $LINK_DEST variables
	DIR_NAME=$TODAY-SUN
	LINK_DEST=$YESTERDAY
	
elif [[ $TODAY == "Mon" ]]; then
	DIR_NAME=$TODAY
	LINK_DEST=$(date --date="2 days ago" +%Y%m%d)
	find -mindepth 1 -maxdepth 1 -type d -mtime +2 ! \( -name "*SUN*" \) -exec rm -rf {} \;

else 
	DIR_NAME=$TODAY
	LINK_DEST=$YESTERDAY
	find -mindepth 1 -maxdepth 1 -type d -mtime +2 ! \( -name "*SUN*" \) -exec rm -rf {} \;
fi

# Make backup directory
mkdir -p /volume1/Host_backups/Example/server.example.com/backups-$DIR_NAME/home

# Run the backups	
rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$LINK_DEST -e "ssh -i /root/.ssh/id_rsa" --delete backup@server.example.com:/mnt/backups/* /volume1/Host_backups/Example/server.example.com/backups-$DIR_NAME

rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$LINK_DEST/home --rsync-path="sudo rsync" -e "ssh -i /root/.ssh/id_rsa" --exclude "virtfs" --delete backup@server.example.com:/home/ /volume1/Host_backups/Example/server.example.com/backups-$DIR_NAME/home/
