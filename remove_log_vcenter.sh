#!/bin/bash

LOG_DIR1= "/storage/log/vmware"
LOG_DIR2="storage/log/vmware/sso"
LOG_DIR="/storage/log"
THRESHOLD=90  

USAGE=$(df -h "$LOG_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "Storage usage in $LOG_DIR exceeds $THRESHOLD%. Deleting logs older than 3 months..."
    

    find "$LOG_DIR1" "$LOG_DIR2" -type f -name "*.log" -mtime +90 -delete

    # Check storage usage again
    USAGE=$(df -h "$LOG_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "Storage usage after deleting logs older than 3 months: $USAGE%"


    while [ "$USAGE" -ge "$THRESHOLD" ]; do
        OLDEST_LOG=$(find "$LOG_DIR1" "$LOG_DIR2" -type f -name "*.log" -printf "%T+ %p\n" | sort | head -n 1 | awk '{print $2}')
        
        if [ -n "$OLDEST_LOG" ]; then
            echo "Storage still exceeds $THRESHOLD%. Deleting oldest log: $OLDEST_LOG"
            rm -f "$OLDEST_LOG"
        else
            echo "No more logs to delete."
            break
        fi


        USAGE=$(df -h "$LOG_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
        echo "Storage usage after deleting one more log: $USAGE%"
    done

    echo "Final storage usage: $USAGE%"
else
    echo "Storage usage in $LOG_DIR is below $THRESHOLD%. No logs need to be deleted."
fi

#crontab -e
# 0 2 * * 6 /path/to/script.sh
