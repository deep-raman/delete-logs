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

# Log delete config
LOG_DIR="/var/www/vhosts/LOGS/s/log/debug/"
LOG_FILE="/var/log/${DATE}_delete_logs.log"
LOG_DAYS="4"

# Log compression config
COMPRESS_DAY="0"

check_log_dir() {
  if [[ ! -d "$LOG_DIR" ]]; then
    echo -e "$TIMESTAMP Log directory not found : $LOG_DIR"
    exit 1
  fi
}

delete_logs() {
  echo -e "" >> "$LOG_FILE"
  echo -e "$TIMESTAMP Checking debug log directories to delete older than $LOG_DAYS days..." >> "$LOG_FILE" 
  LOG_FILES=$(/usr/bin/find "$LOG_DIR" -name "????-??-??" -mtime +$LOG_DAYS)
  if [[ -z "$LOG_FILES" ]]; then
    echo "$TIMESTAMP  No log directories found older than : $LOG_DAYS day/s." >> "$LOG_FILE"
  else
    for LFILE in $LOG_FILES; do
      echo -e "$TIMESTAMP  Deleting log dir : $LFILE" >> "$LOG_FILE"
      /bin/rm -rf "$LFILE"
    done
    echo -e "$TIMESTAMP  Log deletion finished." >> "$LOG_FILE"
  fi
}

compress_dir() {
  if [[ ! -z "$1" ]]; then
    DIR_NAME="$1"
    COMPRESS_DIR_NAME="${DIR_NAME}.tar.gz"
    echo -e "Compressing log directory : $DIR_NAME"
    /bin/tar -zcf "${COMPRESS_DIR_NAME}" "${DIR_NAME}"
    echo -e "OK : Directory compression success : $DIR_NAME"
  else
    echo -e "ERROR : No directory provided for compression."
    exit 1
  fi
}

get_dirs_to_compress() {
  DIRS_TO_COMPRESS=$(/usr/bin/find "$LOG_DIR" -name "????-??-??" -mtime $COMPRESS_DAY)
  echo "$DIRS_TO_COMPRESS"
  if [[ -z "$DIRS_TO_COMPRESS" ]]; then
    MSG="$TIMESTAMP  ERROR: No log directory found to compress."
    echo "$MSG" >> "$LOG_FILE"
    echo "$MSG"
    exit 1
  else
    for CDIR in $DIRS_TO_COMPRESS; do
      compress_dir "$CDIR"
    done
  fi
}


check_log_dir
#delete_logs
get_dirs_to_compress

exit 0

