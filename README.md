# nova-migrate

**Full backup, restore and server-to-server migration utility for Nova Node Agent.**

Designed for Ubuntu/Debian servers running a Nova node installation. It preserves Nova state and configuration without changing the server hostname, domain, IP addresses or existing ports.

## Features

- SQLite-safe Nova database backup using SQLite `.backup`
- `/var/lib/nova` state
- `/etc/nova` configuration and keys
- Xray configuration
- Psiphon configuration/state
- Tor configuration and state
- Sing-box configuration/state when present
- Nova, Geo, Xray, Psiphon, Sing-box and Tor systemd units
- Service enable/disable state
- Nova sysctl tuning files
- Nova logrotate configuration
- Nova Let's Encrypt deploy hook
- SHA256 integrity verification
- Emergency backup before restore
- Server-to-server migration over SSH + rsync
- Automatic backups every 30 minutes
- Seven-day backup retention
- Health check / port inspection

## Requirements

- Ubuntu/Debian
- root access
- SSH access for migration
- A compatible Nova installation on the destination server
- `rsync`, `sqlite3`, `tar`, `systemctl`, `ssh`

The installer installs the required command-line dependencies.

## Install

### One-line installation

```bash
curl -fsSL https://raw.githubusercontent.com/arsamnikzaad/nova-migrate/main/install.sh | bash
```

Or:

```bash
git clone https://github.com/arsamnikzaad/nova-migrate.git
cd nova-migrate
bash install.sh
```

## Commands

```text
nova-migrate backup
nova-migrate restore [BACKUP_DIR]
nova-migrate migrate root@SERVER_IP
nova-migrate list
nova-migrate auto
nova-migrate doctor
nova-migrate version
nova-migrate help
```

## Backup

Create a complete snapshot:

```bash
nova-migrate backup
```

Backups are stored in:

```text
/var/backups/nova/YYYY-MM-DD_HH-MM-SS/
```

Each backup contains a manifest and `SHA256SUMS`.

**Important:** Nova backups can contain credentials, private keys, tokens and service configuration. Treat the backup directory as sensitive data and never commit a backup to Git.

## Restore

Restore the newest backup:

```bash
nova-migrate restore
```

Restore a specific snapshot:

```bash
nova-migrate restore /var/backups/nova/2026-09-18_23-54-09
```

Before restoring, the tool creates an emergency backup of the current Nova/Xray state under:

```text
/var/backups/nova/pre-restore-YYYY-MM-DD_HH-MM-SS/
```

The restore verifies SHA256 checksums before touching the live configuration.

## Server migration

On the source server:

```bash
nova-migrate migrate root@45.135.194.195
```

The command:

1. Creates a fresh source backup.
2. Verifies the snapshot.
3. Creates the backup directory on the destination.
4. Transfers the snapshot with rsync.
5. Transfers the migration utility.
6. Runs restore remotely.
7. Reloads systemd.
8. Starts Nova-related services.
9. Performs SQLite and service health checks.

### SSH authentication

Password authentication works when the destination SSH server permits it. SSH keys are recommended for unattended migrations.

## Automatic backups

Enable a systemd timer:

```bash
nova-migrate auto
```

This runs a backup every 30 minutes and keeps approximately seven days of snapshots.

Check the timer:

```bash
systemctl status nova-migrate-backup.timer
systemctl list-timers nova-migrate-backup.timer
```

## Health check

```bash
nova-migrate doctor
```

This reports:

- Nova database integrity
- Nova-related service state
- listening TCP ports

## What is intentionally not overwritten

The tool does **not** overwrite the Nova application source under `/opt/nova-node-agent`. A compatible Nova installation should exist on the destination first; the migration focuses on persistent state, configuration and service definitions.

It also does not change:

- hostname
- server IP
- DNS
- existing port numbers
- unrelated system services

## Security notes

Backups may contain:

- Nova origin keys
- TLS/private material stored by Nova
- Xray configuration
- Psiphon/Tor state
- service credentials

Store backups with permissions restricted to root and use encrypted storage for off-server copies.

## Recovery

If a restore causes a problem, the pre-restore snapshot can be inspected in:

```text
/var/backups/nova/pre-restore-*/
```

Always verify the service status after restoring:

```bash
nova-migrate doctor
```

## License

MIT License. See [LICENSE](LICENSE).

## Project

GitHub: https://github.com/arsamnikzaad/nova-migrate
