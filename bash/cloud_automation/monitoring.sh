#!/bin/bash

# CONFIG
DISK_THRESHOLD=90        # % занятости диска, после которого реагировать
MEM_THRESHOLD_MB=1024    # процесс, использующий больше X MB памяти — подозрителен
LOOP_CPU_THRESHOLD=90    # процесс, который держит >90% CPU — возможно, в loop
CHECK_INTERVAL=10        # секунд между проверками

while true; do
  echo "=== Watchdog check at $(date) ==="

  # --- Диск: проверка свободного места ---
  USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
  if [ "$USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "[ALERT] Диск почти заполнен: ${USAGE}%"
  fi

  # --- Память и лупы: найди тяжёлые процессы ---
  echo "Проверка памяти и цикличных процессов..."
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 20 | while read pid ppid cmd mem cpu; do
    MEM_INT=${mem%.*}
    CPU_INT=${cpu%.*}

    if [ "$MEM_INT" -gt "$MEM_THRESHOLD_MB" ] || [ "$CPU_INT" -gt "$LOOP_CPU_THRESHOLD" ]; then
      echo "[WARN] PID=$pid MEM=${mem}% CPU=${cpu}% CMD=$cmd"

      # Убить процесс
      echo "→ Убиваем процесс PID=$pid"
      kill -9 "$pid"
    fi
  done

  echo "Ожидание $CHECK_INTERVAL секунд..."
  sleep "$CHECK_INTERVAL"
done
