#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }
systemctl disable --now nova-migrate-backup.timer 2>/dev/null || true
rm -f /etc/systemd/system/nova-migrate-backup.timer /etc/systemd/system/nova-migrate-backup.service
systemctl daemon-reload
rm -f /usr/local/sbin/nova-migrate
echo "nova-migrate removed. Backups under /var/backups/nova were NOT deleted."
