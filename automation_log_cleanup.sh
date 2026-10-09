#!/usr/bin/env bash
# log_cleanup.sh - compress logs older than 7 days, delete after 30 days.
# Usage: ./log_cleanup.sh [/var/log/myapp]
set -euo pipefail
DIR="${1:-/var/log/myapp}"
find "$DIR" -type f -name '*.log' -mtime +7 -exec gzip -f {} \;
find "$DIR" -type f -name '*.gz'  -mtime +30 -delete
echo "Log cleanup complete for $DIR"
