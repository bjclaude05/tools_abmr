#!/usr/bin/env bash
# deploy.sh - deploy a Spring Boot jar with backup of the previous version, health check and automatic rollback.
# Usage: ./deploy.sh <new-app.jar> [service=myapp] [health_url=http://localhost:8080/actuator/health]
set -euo pipefail
NEW_JAR="${1:?Usage: $0 <new-app.jar> [service] [health_url]}"
SERVICE="${2:-myapp}"
HEALTH_URL="${3:-http://localhost:8080/actuator/health}"
APP_DIR="/opt/${SERVICE}"
CURRENT="${APP_DIR}/${SERVICE}.jar"
PREVIOUS="${APP_DIR}/${SERVICE}.jar.previous"

[ -f "$NEW_JAR" ] || { echo "Jar not found: $NEW_JAR"; exit 2; }
mkdir -p "$APP_DIR"

echo "Backing up current version"
[ -f "$CURRENT" ] && cp -p "$CURRENT" "$PREVIOUS"

echo "Installing new version"
install -m 640 "$NEW_JAR" "$CURRENT"
systemctl restart "$SERVICE"

echo "Waiting for health check: $HEALTH_URL"
for i in $(seq 1 30); do
  if curl -fsS "$HEALTH_URL" 2>/dev/null | grep -q '"status":"UP"'; then
    echo "Deployment OK after ${i}x2s"; exit 0
  fi
  sleep 2
done

echo "Health check FAILED - rolling back"
if [ -f "$PREVIOUS" ]; then
  cp -p "$PREVIOUS" "$CURRENT"; systemctl restart "$SERVICE"; echo "Rolled back to previous version"
else
  echo "No previous version available"
fi
exit 1
