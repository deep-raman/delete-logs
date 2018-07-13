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
YEAR=$(/bin/date "+%Y")
MONTH=$(/bin/date "+%m")
DAY=$(/bin/date "+%d")
TIMESTAMP=$(/bin/date "+%Y-%m-%d %H:%M:%S")
HOSTNAME=$(/bin/hostname)
#HOSTNAME=$(echo $HOSTNAME | /bin/cut -d'.' -f1)

# Log delete config
LOG_DIR="/var/www/vhosts/LOGS/s/log/debug/"
LOG_FILE="/var/log/${DATE}_delete_logs.log"
LOG_DAYS="4"

# Log compression config, days to compress old files. Set to 0, to get yesterday's log
COMPRESS_DAY="4"

# AWS Configuration
AWS_BUCKET_NAME="sky-tours-backups"
AWS_BUCKET_REGION="eu-west-1"
AWS_BUCKET_PATH="s3://$AWS_BUCKET_NAME/$YEAR/$HOSTNAME"
AWS_BUCKET_DIR="debug_logs"
AWS_FINAL_PATH="${AWS_FINAL_PATH}/${AWS_BUCKET_DIR}"

check_log_dir() {
  if [[ ! -d "$LOG_DIR" ]]; then
    echo -e "$TIMESTAMP Log directory not found : $LOG_DIR"
    exit 1
  fi
}

delete_logs() {
  if [[ ! -z "$1" ]]; then
    /bin/rm -rf "$1"
  else
    echo -e "ERROR: No directory provided for deletion."
    exit 1
  fi
}

get_dir_to_delete() {
  echo -e "" >> "$LOG_FILE"
  echo -e "$TIMESTAMP Checking debug log directories to delete older than $LOG_DAYS days..." >> "$LOG_FILE" 
  LOG_FILES=$(/usr/bin/find "$LOG_DIR" -name "????-??-??" -mtime +$LOG_DAYS)
  if [[ -z "$LOG_FILES" ]]; then
    echo "$TIMESTAMP  No log directories found older than : $LOG_DAYS day/s." >> "$LOG_FILE"
  else
    for LFILE in $LOG_FILES; do
      echo -e "$TIMESTAMP  Deleting log dir : $LFILE" >> "$LOG_FILE"
      delete_logs "$LFILE"
    done
    echo -e "$TIMESTAMP  Log deletion finished." >> "$LOG_FILE"
  fi
}

check_file_on_s3() {
  if [[ ! -z "$1" ]]; then
    FILE_TO_CHECK="$1"
    FILE_EXISTS_ON_S3=$(/usr/local/bin/aws s3 ls "$FILE_TO_CHECK")
    if [[ -z "$FILE_EXISTS_ON_S3" ]]; then
      echo -e "KO"
    else
      echo "OK"
    fi
  else
    echo -e "ERROR - No file provided to check on AWS S3."
    exit 1
  fi
}

upload_to_s3() {
  echo "in upload"
  if [[ ! -z "${COMPRESSED_DIRS[@]}" ]]; then
    for COMP_DIR in "${COMPRESSED_DIRS[@]}"; do
      echo "$COMP_DIR"
      #MONTH=$(echo "$COMP_DIR" | cut -d"-" -f2)
      #DAY=$(echo "$COMP_DIR" | cut -d"-" -f3 | cut -d"." -f1)
      FILE_EXIST=$(check_file_on_s3 "$FILE_TO_UPLOAD")
      if [[ "$FILE_EXIST" == "KO" ]]; then
        #UPLOAD=$(/usr/local/bin/aws s3 mv "$COMP_DIR" "$AWS_BUCKET_PATH"/"$MONTH"/"$DAY"/"$AWS_BUCKET_DIR"/"$YEAR"-"$MONTH"-"$DAY".tar.gz \
        UPLOAD=$(/usr/local/bin/aws s3 mv "$COMP_DIR" "$AWS_FINAL_PATH" \
        --storage-class REDUCED_REDUNDANCY \
        --region "$AWS_BUCKET_REGION")
        echo "OK: Upload completed."
      else
        echo -e "File already exists on S3"
      fi
    done
  else
    echo -e "ERROR: No compressed dir provided for upload to S3."
    exit 1
  fi
}

compress_dir() {
  COMPRESSED_DIRS=""
  if [[ ! -z "$1" ]]; then
    DIR_NAME="$1"
    COMPRESS_DIR_NAME="${DIR_NAME}.tar.gz"
    #if [[ -f "$COMPRESS_DIR_NAME" && ! -s "$COMPRESS_DIR_NAME" ]]; then
    #  echo -e "Directory already compressed and size is not zero."
    #  echo -e "Ignoring..."
    #else
    echo -e "Compressing log directory : $DIR_NAME"
    #/bin/tar -zcf "${COMPRESS_DIR_NAME}" "${DIR_NAME}"
    echo -e "OK : Directory compression success : $DIR_NAME"
    COMPRESSED_DIRS+=("${COMPRESS_DIR_NAME}")
    echo "${COMPRESSED_DIRS[@]}"
    #fi
  else
    echo -e "ERROR : No directory provided for compression."
    exit 1
  fi
}

get_dirs_to_compress() {
  DIRS_TO_COMPRESS=$(/usr/bin/find "$LOG_DIR" -name "????-??-??" -mtime -$LOG_DAYS)
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
#get_dir_to_delete
get_dirs_to_compress
upload_to_s3

exit 0