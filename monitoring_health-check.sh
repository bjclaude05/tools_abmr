#!/usr/bin/env bash
# health-check.sh - disk, memory, load, services and ports in one run.
# Exit codes follow monitoring-plugin convention: 0 OK, 1 WARNING, 2 CRITICAL.
# Usage: ./health-check.sh [-S "nginx ssh"] [-P "80 443"]
set -uo pipefail
SERVICES="ssh"; PORTS="22"
DISK_WARN=80; DISK_CRIT=90; MEM_WARN=85; MEM_CRIT=95
while getopts "S:P:" o; do case "$o" in S) SERVICES="$OPTARG";; P) PORTS="$OPTARG";; esac; done

status=0
flag() { [ "$1" -gt "$status" ] && status="$1"; }
echo "== Health check $(hostname -s) $(date '+%F %T') =="

# Disk usage per mount
while read -r use mount; do
  pct="${use%\%}"
  if   [ "$pct" -ge "$DISK_CRIT" ]; then echo "CRITICAL disk $mount ${pct}%"; flag 2
  elif [ "$pct" -ge "$DISK_WARN" ]; then echo "WARNING  disk $mount ${pct}%"; flag 1
  else echo "OK       disk $mount ${pct}%"; fi
done < <(df -P -x tmpfs -x devtmpfs | awk 'NR>1{print $5, $6}')

# Memory
mem=$(free | awk '/Mem:/{printf "%d", $3/$2*100}')
if   [ "$mem" -ge "$MEM_CRIT" ]; then echo "CRITICAL memory ${mem}%"; flag 2
elif [ "$mem" -ge "$MEM_WARN" ]; then echo "WARNING  memory ${mem}%"; flag 1
else echo "OK       memory ${mem}%"; fi

# Load vs CPU count
cpus=$(nproc); load=$(awk '{print $1}' /proc/loadavg)
if awk "BEGIN{exit !($load > $cpus*2)}"; then echo "CRITICAL load $load (cpus=$cpus)"; flag 2
elif awk "BEGIN{exit !($load > $cpus)}"; then echo "WARNING  load $load (cpus=$cpus)"; flag 1
else echo "OK       load $load (cpus=$cpus)"; fi

# Services
for s in $SERVICES; do
  if systemctl is-active --quiet "$s" 2>/dev/null; then echo "OK       service $s"
  else echo "CRITICAL service $s not active"; flag 2; fi
done

# Listening ports
for p in $PORTS; do
  if ss -ltn "( sport = :$p )" 2>/dev/null | grep -q LISTEN; then echo "OK       port $p listening"
  else echo "CRITICAL port $p not listening"; flag 2; fi
done
exit "$status"
