#!/bin/bash

# cloud-automation.sh - AWS automation script for fixing disk, memory, and CPU issues

# AWS Setup (simulate tagging)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
TAG_VALUE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=RunAutomation" --region us-east-1 --query "Tags[0].Value" --output text)

if [ "$TAG_VALUE" != "true" ]; then
  echo "[INFO] Tag RunAutomation != true. Exiting."
  exit 0
fi

# Set thresholds
DISK_THRESHOLD=85
MEM_THRESHOLD_MB=1024
CPU_THRESHOLD=85

# Logging
LOG_FILE="/var/log/cloud-automation-fix.log"
echo "[$(date)] Starting system scan..." >> $LOG_FILE

# Disk check
USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
if [ "$USAGE" -gt "$DISK_THRESHOLD" ]; then
  echo "[$(date)] High disk usage detected: ${USAGE}%" | tee -a $LOG_FILE
  # Cleanup actions
  rm -rf /tmp/* /var/tmp/*
  journalctl --vacuum-time=1d
  echo "[$(date)] Cleaned temporary files and logs." >> $LOG_FILE
fi

# Memory and CPU heavy processes
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 20 | while read pid ppid cmd mem cpu; do
  MEM_INT=${mem%.*}
  CPU_INT=${cpu%.*}
  if [ "$MEM_INT" -gt "$MEM_THRESHOLD_MB" ] || [ "$CPU_INT" -gt "$CPU_THRESHOLD" ]; then
    echo "[$(date)] Killing heavy process PID=$pid (MEM=$mem%, CPU=$cpu%) CMD=$cmd" | tee -a $LOG_FILE
    kill -9 "$pid"
  fi
done

# Upload log to S3
aws s3 cp $LOG_FILE s3://cloud-automation-logs/$(hostname)-$(date +%s).log

echo "[$(date)] System scan and remediation complete." | tee -a $LOG_FILE

# Notify via SNS
aws sns publish --topic-arn arn:aws:sns:us-east-1:123456789012:cloud-automation-topic --message "System remediation run complete on $INSTANCE_ID" --region us-east-1

exit 0
