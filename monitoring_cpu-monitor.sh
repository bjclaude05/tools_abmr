#!/usr/bin/env bash
# cpu-monitor.sh - top CPU and memory consumers plus load, appended to a log (run from cron).
# Cron example: */5 * * * * /opt/tools/monitoring/cpu-monitor.sh
set -euo pipefail
LOG="${LOG:-/var/log/cpu-monitor.log}"
{
  echo "=== $(date '+%F %T') load: $(cut -d' ' -f1-3 /proc/loadavg)"
  ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -6
} >> "$LOG"
