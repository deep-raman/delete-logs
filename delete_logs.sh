#!/bin/bash

##########################################################################################################
#
#  Author        :  Raman Deep
#  Email         :  raman@sky-tours.com
#  Date          :  12 June 2018
#  Description   :  Script to delete debug logs on stat01 
#  Version       :  1.0
#
##########################################################################################################


# Date and hostname variables
DATE=$(/bin/date "+%Y%m%d")
TIMESTAMP=$(/bin/date "+%Y-%m-%d %H:%M:%S")
#HOSTNAME=$(/bin/hostname)
#HOSTNAME=$(echo $HOSTNAME | /bin/cut -d'.' -f1)

# Log config
LOG_DIR="/var/www/vhosts/LOGS/s/log/debug/"
LOG_FILE="/var/log/${DATE}_delete_logs.log"
LOG_DAYS="4"

check_log_dir() {
  if [[ ! -d "$LOG_DIR" ]]; then
    echo -e "$TIMESTAMP Log directory not found : $LOG_DIR"
    exit 1
  fi
}

delete_logs() {
  echo -e "" >> "$LOG_FILE"
  echo -e "$TIMESTAMP Checking debug log directories to delete older than $LOG_DAYS days..." >> "$LOG_FILE" 
  LOG_FILES=$(/bin/find "$LOG_DIR" -name "????-??-??" -mtime +$LOG_DAYS)
  if [[ -z "$LOG_FILES" ]]; then
    echo "$TIMESTAMP  No log directories found older than : $LOG_DAYS day/s." >> "$LOG_FILE"
  else
    for LFILE in $LOG_FILES; do
      /bin/rm -rf "$LFILE"
      echo -e "$TIMESTAMP  Deleting log dir : $LFILE" >> "$LOG_FILE"
    done
    echo -e "$TIMESTAMP  Log deletion finished." >> "$LOG_FILE"
  fi
}

check_log_dir
delete_logs

exit 0

