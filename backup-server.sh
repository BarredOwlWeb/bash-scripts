#!/bin/bash
DATE=$(date +%Y%m%d)
SUNDAY=$(date +%a)
YESTERDAY=$(date --date="1 day ago" +%Y%m%d)

mkdir -p /volume1/Host_backups/Example/server.example.com/backups-$DATE/home
    rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$YESTERDAY -e "ssh -i /root/.ssh/id_rsa" --delete backup@server.example.com:/mnt/backups/* /volume1/Host_backups/Example/server.example.com/backups-$DATE
	    rsync -aPH --link-dest=/volume1/Host_backups/Example/server.example.com/backups-$YESTERDAY/home --rsync-path="sudo rsync" -e "ssh -i /root/.ssh/id_rsa" --exclude "virtfs" --delete backup@server.example.com:/home/ /volume1/Host_backups/Example/server.example.com/backups-$DATE/home/


if [[ $SUNDAY == "Sun" ]]; then
	find -type d -maxdepth 1 -mtime +29 -exec rm -rf {} \;
fi


find -type d -maxdepth 1 -mtime +3 -mtime -7
chown -R Example.users /volume1/Host_backups/Example/server.example.com/
