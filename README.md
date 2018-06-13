# delete-logs

This scripts find the pattern in the path and deletes the files/folders found older than 4 days. 

These variables can be personalized with the desired ones :


  LOG_DIR="/var/www/vhosts/LOGS/s/log/debug/"
  LOG_DAYS="4"
  LOG_FILES=$(/bin/find "$LOG_DIR" -name "????-??-??" -mtime +$LOG_DAYS)

The script can be used to run periodically using cronjob.

Author : Raman Deep
Date : 12 June 2018
deep.raman85@gmail.com
