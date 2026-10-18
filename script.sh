#!/bin/bash

set -u

INTERVAL=10
LOG_FILE="${LOG_FILE:-monitor.log}"
ITERATIONS="${ITERATIONS:-0}"

log_err() { echo "Ошибка: $*" >&2; }

for cmd in free df uptime date; do
    command -v "$cmd" >/dev/null 2>&1 || { log_err "не найдена команда $cmd"; exit 1; }
done

[[ "$ITERATIONS" =~ ^[0-9]+$ ]] || { log_err "ITERATIONS должно быть числом, получено: $ITERATIONS"; exit 2; }

LOG_DIR="$(dirname "$LOG_FILE")"
mkdir -p "$LOG_DIR" 2>/dev/null || { log_err "не удалось создать каталог $LOG_DIR"; exit 3; }
touch "$LOG_FILE" 2>/dev/null   || { log_err "нет прав на запись в $LOG_FILE"; exit 3; }

on_stop() {
    echo "--- $(date "+%Y-%m-%d %H:%M:%S") остановлен ---" >> "$LOG_FILE"
    exit 0
}
trap on_stop INT TERM

count=0
while true; do
    ts="$(date "+%Y-%m-%d %H:%M:%S")"
    {
        echo "--- $ts ---"
        free -h
        df -h
        uptime
        echo
    } >> "$LOG_FILE"

    count=$((count + 1))
    echo "$ts snapshot -> $LOG_FILE"

    if [ "$ITERATIONS" -gt 0 ] && [ "$count" -ge "$ITERATIONS" ]; then
        break
    fi

    sleep "$INTERVAL" &
    wait $!
done
