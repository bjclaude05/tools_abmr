#!/usr/bin/env bash
# restore-test.sh - proves a backup is usable: verify checksum, list, extract to a temp dir.
# Usage: ./restore-test.sh /var/backups/app/host-20260101-020000.tar.gz
set -euo pipefail
ARCHIVE="${1:?Usage: $0 <archive.tar.gz>}"

echo "[1/3] Verifying checksum"
sha256sum -c "${ARCHIVE}.sha256"

echo "[2/3] Checking archive integrity"
tar -tzf "$ARCHIVE" > /dev/null

echo "[3/3] Test restore to temporary directory"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
tar -xzf "$ARCHIVE" -C "$TMP"
echo "Restored $(find "$TMP" -type f | wc -l) files - restore test PASSED"
