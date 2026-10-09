# Recovery Procedure (lab runbook)

Targets (example): **RTO 4 hours, RPO 24 hours** for application servers; adjust to the system owner's requirements.

## 1. Declare and assess
1. Confirm the incident and its scope (single service, server, or site).
2. Notify the system owner and the service desk; open an incident record.
3. Decide: restart/repair in place, restore from backup, or fail over to the DR site.

## 2. Restore from backup
1. Identify the latest good archive: `ls -lt /var/backups/app/` and verify with `restore-test.sh`.
2. Rebuild the base server (OS, Java 21, Nginx) using `infrastructure/linux-setup` scripts.
3. Extract configuration: `tar -xzf <archive> -C /`.
4. Restore the database from the DBA team's latest dump (outside this repo).
5. Start services in order: database, application, Nginx.

## 3. Validate
- `./monitoring/health-check.sh -S "myapp nginx" -P "80 443"` returns exit code 0.
- Application health endpoint reports `UP`.
- Business owner completes a smoke test (login, one sample transaction).

## 4. Close
- Review logs for the root cause, record time to recover versus RTO, update this runbook.
- Run a recovery drill at least twice a year and keep the result.
