# nova-migrate


# 🇮🇷 راهنمای فارسی

## معرفی

**nova-migrate** یک ابزار خط فرمان برای بکاپ کامل، Restore و انتقال سرور به سرور **Nova Node Agent** است.

این ابزار برای سرورهای Ubuntu/Debian طراحی شده و هدف آن انتقال State، دیتابیس، تنظیمات و سرویس‌های مرتبط Nova بدون تغییر خودکار **IP، hostname، DNS یا پورت‌های موجود سرور مقصد** است.

## امکانات

- بکاپ امن SQLite با مکانیزم SQLite Backup
- بکاپ کامل /var/lib/nova
- بکاپ کامل /etc/nova
- بکاپ تنظیمات Xray
- بکاپ تنظیمات و State مربوط به Psiphon
- بکاپ تنظیمات و State مربوط به Tor
- بکاپ Sing-box در صورت وجود
- ذخیره Service Unitهای Nova و سرویس‌های مرتبط
- شناسایی سرویس‌های nova-geo-*
- ذخیره وضعیت Enable/Disable سرویس‌ها
- بکاپ Sysctlهای Nova
- بکاپ Logrotate
- بکاپ Hook تمدید SSL مربوط به Nova
- SHA256 برای بررسی صحت فایل‌های بکاپ
- Emergency Backup قبل از Restore
- انتقال مستقیم با SSH و rsync
- بکاپ خودکار هر ۳۰ دقیقه
- Retention حدود ۷ روز
- دستور doctor برای بررسی سلامت
- بررسی پورت‌های Listening
- Lock برای جلوگیری از اجرای همزمان عملیات

## ⚠️ امنیت

بکاپ Nova ممکن است شامل Private Key، Token، Credential، تنظیمات Xray و اطلاعات حساس سرویس‌ها باشد.

**هرگز بکاپ را داخل GitHub یا Repository عمومی قرار ندهید.**

پوشه زیر باید خصوصی بماند:

~~~~text
/var/backups/nova/
~~~~

## نصب

### نصب یک‌خطی

~~~~bash
curl -fsSL https://github.com/arsamnikzaad/nova-migrate/raw/refs/heads/main/install.sh | bash
~~~~

### نصب دستی

~~~~bash
git clone https://github.com/arsamnikzaad/nova-migrate.git
cd nova-migrate
bash install.sh
~~~~

بعد از نصب:

~~~~bash
nova-migrate version
nova-migrate help
~~~~

محل نصب:

~~~~text
/usr/local/sbin/nova-migrate
~~~~

## ساخت بکاپ

~~~~bash
nova-migrate backup
~~~~

بکاپ‌ها در مسیر زیر ساخته می‌شوند:

~~~~text
/var/backups/nova/YYYY-MM-DD_HH-MM-SS/
~~~~

مشاهده بکاپ‌ها:

~~~~bash
nova-migrate list
~~~~

هر Snapshot شامل Manifest و فایل SHA256SUMS است.

## Restore

### آخرین بکاپ

~~~~bash
nova-migrate restore
~~~~

### بکاپ مشخص

~~~~bash
nova-migrate restore /var/backups/nova/2026-09-18_23-54-09
~~~~

قبل از Restore، ابزار یک Emergency Backup از وضعیت فعلی Nova و Xray می‌سازد.

سپس:

1. صحت SHA256 بررسی می‌شود.
2. سرویس‌های مرتبط متوقف می‌شوند.
3. State و Configuration بازیابی می‌شوند.
4. Systemd Reload می‌شود.
5. وضعیت Enable/Disable سرویس‌ها بازیابی می‌شود.
6. سرویس‌ها دوباره اجرا می‌شوند.
7. سلامت SQLite بررسی می‌شود.
8. Nova Agent و Xray بررسی می‌شوند.
9. پورت‌های Listening نمایش داده می‌شوند.

## 🚀 انتقال کامل به سرور جدید

از روی سرور قدیمی اجرا کنید:

~~~~bash
nova-migrate migrate root@SERVER_IP
~~~~

مثال:

~~~~bash
nova-migrate migrate root@45.135.194.195
~~~~

فرآیند Migration کاملاً خودکار است:

1. ساخت بکاپ جدید روی سرور مبدأ
2. بررسی سلامت بکاپ
3. ساخت مسیر بکاپ روی مقصد
4. انتقال با rsync
5. انتقال ابزار nova-migrate
6. اجرای Restore روی سرور مقصد
7. Reload کردن Systemd
8. اجرای سرویس‌های Nova
9. بررسی SQLite
10. بررسی Nova Agent و Xray
11. نمایش پورت‌های فعال

### پیش‌نیاز مقصد

بهتر است سرور مقصد یک نصب سازگار و سالم از Nova داشته باشد.

SSH را قبل از Migration تست کنید:

~~~~bash
ssh root@SERVER_IP
~~~~

برای Migrationهای مکرر، SSH Key توصیه می‌شود.

## 🔄 بکاپ خودکار

برای فعال‌سازی بکاپ هر ۳۰ دقیقه:

~~~~bash
nova-migrate auto
~~~~

Retention حدود ۷ روز است.

بررسی Timer:

~~~~bash
systemctl status nova-migrate-backup.timer
systemctl list-timers nova-migrate-backup.timer
~~~~

مشاهده لاگ:

~~~~bash
journalctl -u nova-migrate-backup.service -n 50 --no-pager
~~~~

## 🩺 بررسی سلامت

~~~~bash
nova-migrate doctor
~~~~

این دستور سلامت دیتابیس، وضعیت سرویس‌های Nova و پورت‌های Listening را نمایش می‌دهد.

## دستورات کامل

| دستور | کاربرد |
|---|---|
| nova-migrate backup | ساخت بکاپ کامل |
| nova-migrate restore | Restore آخرین بکاپ |
| nova-migrate restore PATH | Restore بکاپ مشخص |
| nova-migrate migrate root@IP | انتقال به سرور جدید |
| nova-migrate list | نمایش بکاپ‌ها |
| nova-migrate auto | فعال‌سازی بکاپ خودکار |
| nova-migrate doctor | بررسی سلامت |
| nova-migrate version | نمایش نسخه |
| nova-migrate help | نمایش راهنما |

## سناریوی پیشنهادی تعویض سرور

روی سرور قدیمی:

~~~~bash
nova-migrate doctor
nova-migrate backup
nova-migrate list
nova-migrate migrate root@NEW_SERVER_IP
~~~~

روی سرور جدید:

~~~~bash
nova-migrate doctor
~~~~

## عیب‌یابی

### بررسی نصب

~~~~bash
command -v nova-migrate
~~~~

### بررسی SQLite

~~~~bash
sqlite3 /var/lib/nova/nova.db 'PRAGMA integrity_check;'
~~~~

خروجی سالم:

~~~~text
ok
~~~~

### بررسی Nova

~~~~bash
systemctl status nova-agent.service --no-pager
~~~~

### بررسی Xray

~~~~bash
systemctl status xray.service --no-pager
~~~~

### بررسی پورت‌ها

~~~~bash
ss -lntp
~~~~

### لاگ Nova

~~~~bash
journalctl -u nova-agent.service -n 100 --no-pager
~~~~

## چه چیزهایی عمداً جایگزین نمی‌شوند؟

سورس برنامه Nova در مسیر زیر عمداً overwrite نمی‌شود:

~~~~text
/opt/nova-node-agent
~~~~

بهتر است مقصد ابتدا Nova سازگار را داشته باشد و سپس State و Configuration منتقل شوند.

این ابزار همچنین نباید به‌صورت خودکار موارد زیر را تغییر دهد:

- IP سرور
- Hostname
- DNS
- پورت‌های موجود
- سرویس‌های غیرمرتبط

## حذف

~~~~bash
bash uninstall.sh
~~~~

Uninstall ابزار را حذف می‌کند اما بکاپ‌های موجود در /var/backups/nova را حذف نمی‌کند.

---

# 🇬🇧 English Guide


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
curl -fsSL https://github.com/arsamnikzaad/nova-migrate/raw/refs/heads/main/install.sh | bash
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

---

# 🔗 رابطه با پروژه اصلی Nova Server

**nova-migrate یک ابزار جانبی برای پروژه اصلی Nova Server است و خود پنل Nova نیست.**

پروژه اصلی:

**IRNova/Nova-Server**

https://github.com/IRNova/Nova-Server

Nova Server یک پنل و Node Agent خودمیزبان برای مدیریت سرویس‌هایی مانند **Xray-core، sing-box، Hysteria2، WireGuard و AmneziaWG** است. پروژه اصلی همچنین قابلیت‌هایی مانند مدیریت چند Node، کاربران، Subscription، SSL و Telegram Bot/Mini App را ارائه می‌کند.

این پروژه (`nova-migrate`) برای **Backup / Restore / Migration اطلاعات و State مربوط به نصب Nova Server** ساخته شده است.

## این ابزار چه چیزی را مدیریت می‌کند؟

```text
IRNova/Nova-Server
        │
        ├── Nova Node Agent
        ├── Nova database / state
        ├── Xray
        ├── sing-box
        ├── Psiphon
        ├── Tor
        ├── Nova Geo services
        ├── systemd services
        └── Nova configuration
                 │
                 ▼
             nova-migrate
        Backup / Restore / Migration
```

### پروژه اصلی

https://github.com/IRNova/Nova-Server

### ابزار Migration

https://github.com/arsamnikzaad/nova-migrate

> **مهم:** `nova-migrate` جایگزین Nova Server نیست. ابتدا باید Nova Server یا یک نصب سازگار از Nova روی سرور مقصد وجود داشته باشد؛ سپس این ابزار State و Configuration را منتقل می‌کند.

## 🧩 ارتباط با نسخه‌های Nova

به دلیل اینکه ساختار فایل‌ها، سرویس‌ها و دیتابیس Nova ممکن است در نسخه‌های مختلف تغییر کند، قبل از Migration بین نسخه‌های متفاوت، سازگاری نسخه مقصد را بررسی کنید.

برای بررسی وضعیت نصب:

```bash
nova-migrate doctor
```

برای دریافت و نصب خود Nova، همیشه به Repository رسمی پروژه مراجعه کنید:

https://github.com/IRNova/Nova-Server

## ⚡ مسیر پیشنهادی Nova + Migration

### 1. نصب Nova Server

طبق مستندات رسمی Nova:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/IRNova/Nova-Server/main/nova-node.sh)
```

### 2. نصب nova-migrate

```bash
curl -fsSL https://github.com/arsamnikzaad/nova-migrate/raw/refs/heads/main/install.sh | bash
```

### 3. ساخت Backup

```bash
nova-migrate backup
```

### 4. انتقال به سرور جدید

```bash
nova-migrate migrate root@NEW_SERVER_IP
```

### 5. بررسی مقصد

```bash
nova-migrate doctor
```

## ⚖️ Attribution

Nova Server یک پروژه مستقل است که توسط **IRNova** نگهداری می‌شود.

این Repository **Repository رسمی Nova Server نیست** و جایگزین آن نیست.

Repository رسمی Nova Server:

https://github.com/IRNova/Nova-Server

برای دریافت نسخه‌های Nova، مستندات، Installerها و تغییرات پروژه اصلی، به Repository رسمی مراجعه کنید.
