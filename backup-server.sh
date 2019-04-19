#!/bin/bash
DATE=$(date +%Y%m%d)
TODAY=$(date +%a)
YESTERDAY=$(date --date="1 day ago" +%Y%m%d)

if [[ $TODAY == "Sun" ]]; then
	# Delete anything older than 35 days
	find -mindepth 1 -maxdepth 1 -type d -mtime +35 -exec rm -rf {} \;
	mkdir -p /volume1/Host_backups/Example/server.example.com/backups-$DATE-SUN/home
	rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$YESTERDAY -e "ssh -i /root/.ssh/id_rsa" --delete backup@server.example.com:/mnt/backups/* /volume1/Host_backups/Example/server.example.com/backups-$DATE-SUN
  
	rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$YESTERDAY/home --rsync-path="sudo rsync" -e "ssh -i /root/.ssh/id_rsa" --exclude "virtfs" --delete backup@server.example.com:/home/ /volume1/Host_backups/Example/server.example.com/backups-$DATE-SUN/home/

	# Delete any other directories that are older than 2 days, that do not contain "SUN" in the dir name
	find -mindepth 1 -maxdepth 1 -type d -mtime +2 ! \( -name "*SUN*" \) -exec rm -rf {} \;

else
	mkdir -p /volume1/Host_backups/Example/server.example.com/backups-$DATE/home

	if [[ $TODAY == "Mon" ]]; then

	else
        
	rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$YESTERDAY -e "ssh -i /root/.ssh/id_rsa" --delete backup@server.example.com:/mnt/backups/* /volume1/Host_backups/Example/server.example.com/backups-$DATE
        rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$YESTERDAY/home --rsync-path="sudo rsync" -e "ssh -i /root/.ssh/id_rsa" --exclude "virtfs" --delete backup@server.example.com:/home/ /volume1/Host_backups/Example/server.example.com/backups-$DATE/home/

fi

find -mindepth 1 -maxdepth 1 -type d -mtime +2 ! \( -name "*SUN*" \) -exec rm -rf {} \;
chown -R Example.users /volume1/Host_backups/Example/server.example.com/
