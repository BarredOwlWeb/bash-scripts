#!/bin/bash

#################
#
# This script was originally written by David White, founder of Develop CENTS.
# You may use, modify and distribute this script.
# 
# This is a script included in our "Backup Scripts" GitHub repository that we have made publicly available.
# The repo contains Various scripts to backup MySQL databases & other web server assets.
# Visit https://github.com/DevelopCENTS/backup-scripts
#
# Learn more about Develop CENTS at https://developcents.com.
# Follow us on Twitter at @developcents
# 
# Follow David on Twitter, @davidmwhite
#
#
# INSTRUCTIONS:
# 1) Create your backup directory /mnt/backups/mysql/daily and /mnt/backups/mysql/weekly
# 2) Edit your /etc/my.cnf file and append the following lines:
#	[mysqldump]
#	user = backup
#	password = CHANGE-ME
#
# 3) Create a "backup" user in MySQL, and give it read-only access to all databases on the system, using the same password used in step 2.
# 4) Update this file (below) by replacing "CHANGE-ME" with the same password.
# 5) chmod this file to 700
# 6) Run this script whenever you like, and/or setup a crontab entry to run nightly. 
#
#########################33

#LOG=$mysql-backup.log
#exec > $LOG 2>&1

DATABASES=$(echo 'show databases;' | mysql -u backup --password='CHANGE-ME' | grep -v ^Database$)
LIST=$(echo $DATABASES | sed -e "s/\s/\n/g")
DATE=$(date +%Y%m%d)
SUNDAY=$(date +%a)

for i in $LIST; do
if [[ $i != "mysql" ]]; then
	/bin/nice mysqldump --single-transaction $i > /mnt/backups/mysql/daily/$i.$DATE.sql
	find /mnt/backups/mysql/daily/* -type f -mtime +0 -exec rm -f {} \;

	if [[ $SUNDAY == "Sun" ]]; then
		cp /mnt/backups/mysql/daily/$i.$DATE.sql /mnt/backups/mysql/weekly/$i.$DATE.sql
		find /mnt/backups/mysql/weekly/* -type f -mtime +1 -exec rm -f {} \;
	fi
fi

find /mnt/backups/mysql/daily/* -name "*.sql" -exec gzip {} \;
find /mnt/backups/mysql/weekly/* -name "*.sql" -exec gzip {} \;
chown -R backup.backup /mnt/backups/mysql
done

