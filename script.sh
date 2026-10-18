#!/bin/bash

INTERVAL=10
LOG=monitor.log

while true; do
    echo "--- $(date "+%Y-%m-%d %H:%M:%S") ---" >> $LOG
    free -h >> $LOG
    df -h >> $LOG
    uptime >> $LOG
    echo >> $LOG
    sleep $INTERVAL
done
