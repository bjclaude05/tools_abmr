#!/usr/bin/env bash
# backup.sh - compressed, checksummed backup with retention.
# Usage: ./backup.sh [-s "/etc /var/www"] [-d /var/backups/ifmis] [-r 7]
# Lab example: adjust paths for your own environment.
set -euo pipefail

SOURCES="/etc /var/www"
DEST="/var/backups/app"
RETENTION_DAYS=7
HOST="$(hostname -s)"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="${DEST}/backup.log"

while getopts "s:d:r:h" opt; do
  case "$opt" in
    s) SOURCES="$OPTARG" ;;
    d) DEST="$OPTARG"; LOG="${DEST}/backup.log" ;;
    r) RETENTION_DAYS="$OPTARG" ;;
    h|*) echo "Usage: $0 [-s \"dirs\"] [-d dest] [-r retention_days]"; exit 2 ;;
  esac
done

mkdir -p "$DEST"
log() { echo "$(date '+%F %T') [$HOST] $*" | tee -a "$LOG"; }

ARCHIVE="${DEST}/${HOST}-${STAMP}.tar.gz"
log "Starting backup of: ${SOURCES}"

# shellcheck disable=SC2086
if tar --warning=no-file-changed -czf "$ARCHIVE" $SOURCES 2>>"$LOG"; then
  sha256sum "$ARCHIVE" > "${ARCHIVE}.sha256"
  chmod 600 "$ARCHIVE" "${ARCHIVE}.sha256"
  log "OK archive=${ARCHIVE} size=$(du -h "$ARCHIVE" | cut -f1)"
else
  log "ERROR backup failed"; rm -f "$ARCHIVE"; exit 1
fi

# Retention: delete archives older than N days
find "$DEST" -name "${HOST}-*.tar.gz*" -mtime +"$RETENTION_DAYS" -print -delete | sed 's/^/removed: /' | tee -a "$LOG" || true
log "Backup finished"
