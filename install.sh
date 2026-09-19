#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y bash coreutils findutils tar gzip openssh-client rsync sqlite3 util-linux iproute2
install -m 0755 nova-migrate /usr/local/sbin/nova-migrate
echo
echo "Installed: /usr/local/sbin/nova-migrate"
echo "Run: nova-migrate help"
