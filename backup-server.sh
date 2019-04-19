#!/bin/bash
DATE=$(date +%Y%m%d)
TODAY=$(date +%a)
YESTERDAY=$(date --date="1 day ago" +%Y%m%d)

if [[ $TODAY == "Sun" ]]; then
	# Delete anything older than 35 days
	find -mindepth 0 -maxdepth 0 -type d -mtime +35 -exec rm -rf {} \;

	# Set $DIR_NAME and $LINK_DEST variables
	DIR_NAME=$DATE-SUN
	LINK_DEST=$YESTERDAY
	
elif [[ $TODAY == "Mon" ]]; then
	DIR_NAME=$DATE
	LINK_DEST=$(date --date="2 days ago" +%Y%m%d)

else 
	DIR_NAME=$DATE
	LINK_DEST=$YESTERDAY
fi

# Make backup directory
mkdir -p /volume1/Host_backups/Example/server.example.com/backups-$DIR_NAME/home

# Run the backups	
rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$LINK_DEST -e "ssh -i /root/.ssh/id_rsa" --delete backup@server.example.com:/mnt/backups/* /volume1/Host_backups/Example/server.example.com/backups-$DIR_NAME
rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$LINK_DEST/home --rsync-path="sudo rsync" -e "ssh -i /root/.ssh/id_rsa" --exclude "virtfs" --delete backup@server.example.com:/home/ /volume1/Host_backups/Example/server.example.com/backups-$DIR_NAME/home/

# Cleanup - Delete backup older than 2 days that does not contain "SUN" in the parent directory name
find -mindepth 0 -maxdepth 0 -type d -mtime +2 ! \( -name "*SUN*" \) -exec rm -rf {} \;
