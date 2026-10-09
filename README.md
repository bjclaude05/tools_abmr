# Operations Tools - automation, backup, monitoring, recovery

Lab scripts for enterprise Linux administration, written to demonstrate practical sysadmin work. All scripts are plain Bash, use `set -euo pipefail`, take parameters, log their actions, and use meaningful exit codes. Test them in a lab before using on a real server.

| Folder | Script | What it does |
|---|---|---|
| `backup/` | `backup.sh` | Compressed backup, SHA-256 checksum, retention clean-up, logging |
| `backup/` | `restore-test.sh` | Verifies checksum and integrity and performs a test restore |
| `monitoring/` | `health-check.sh` | Disk, memory, load, services and ports, OK/WARNING/CRITICAL exit codes |
| `monitoring/` | `cpu-monitor.sh` | Logs load and top consumers (cron) |
| `automation/` | `deploy.sh` | Deploys a jar, health-checks it, rolls back automatically on failure |
| `automation/` | `log_cleanup.sh` | Compresses and removes old logs |
| `recovery/` | `recovery-procedure.md` | Recovery runbook with RTO/RPO and validation steps |

## Quick start
```bash
chmod +x */*.sh
sudo ./backup/backup.sh -s "/etc /var/www" -d /var/backups/app -r 7
sudo ./backup/restore-test.sh /var/backups/app/<archive>.tar.gz
./monitoring/health-check.sh -S "ssh nginx" -P "22 80"; echo "exit=$?"
```

## Mapping to common sysadmin requirements
Automation of recurring tasks (`automation/`), backup and recovery (`backup/`, `recovery/`), monitoring and availability (`monitoring/`), deployment support (`deploy.sh`).
