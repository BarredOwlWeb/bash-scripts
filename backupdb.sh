#!/bin/bash

#################
#
# This script was originally written by David White, founder of Barred Owl Web
# You may use, modify and distribute this script.
# 
# This is a script included in our "Backup Scripts" GitHub repository that we have made publicly available.
# The repo contains Various scripts to backup MySQL databases & other web server assets.
# Visit https://github.com/BarredOwlWeb
#
# Learn more about Barred Owl Web at https://barredowlweb.com.
# Follow us on Twitter at @BarredOwlWeb
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

DAILY_RETENTION=+0 # how many 24 hour periods to keep locally
WEEKLY_RETENTION=+1 # home many 24 hour periods to keep in weekly folder
FOLDER=/mnt/backups/mariadb
PASS="CHANGE-ME"
DATABASES=$(echo 'show databases;' | mysql -u backup --password='CHANGE-ME' | grep -v ^Database$)
LIST=$(echo $DATABASES | sed -e "s/\s/\n/g")
DATE=$(date +%Y%m%d)
SUNDAY=$(date +%a)

for i in $LIST; do
	# ignore certain DBs
	if [[ $i == "mysql" || $i == "sys" ]]; then
		continue
	fi

	# redirect stderr to stdout, then redirect the regular stdout to the backup file. Order is important
	OUTPUT=`/bin/nice mysqldump --single-transaction --password=$PASS $i 2>&1 > $FOLDER/daily/$i.$DATE.sql `
	if [[ $OUTPUT != "" ]]; then
		echo Problem with database "$i"
		echo ====
		echo $OUTPUT
	fi

	# remove files older than 24 hrs
	find $FOLDER/daily/* -type f -mtime $DAILY_RETENTION -exec rm -f {} \;

	if [[ $SUNDAY == "Sun" ]]; then
		cp $FOLDER/daily/$i.$DATE.sql $FOLDER/weekly/$i.$DATE.sql
		find $FOLDER/weekly/* -type f -mtime $WEEKLY_RETENTION -exec rm -f {} \;
	fi

	find $FOLDER/daily/ -name "*.sql" -exec gzip -f {} \;
	find $FOLDER/weekly/ -name "*.sql" -exec gzip -f {} \;
	chown -R backup.backup $FOLDER
done
