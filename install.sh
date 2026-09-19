#!/usr/bin/env bash
set -Eeuo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }

REPO_RAW="https://raw.githubusercontent.com/arsamnikzaad/nova-migrate/main"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

export DEBIAN_FRONTEND=noninteractive

echo "[1/3] Installing dependencies..."
apt-get update
apt-get install -y bash coreutils findutils tar gzip openssh-client rsync sqlite3 util-linux iproute2 curl

echo "[2/3] Downloading nova-migrate..."
curl -fL --retry 3 --retry-delay 2 -o "$TMP_DIR/nova-migrate" "$REPO_RAW/nova-migrate"
chmod 0755 "$TMP_DIR/nova-migrate"
install -m 0755 "$TMP_DIR/nova-migrate" /usr/local/sbin/nova-migrate

echo "[3/3] Verifying installation..."
/usr/local/sbin/nova-migrate version

echo
echo "Installed: /usr/local/sbin/nova-migrate"
echo "Run: nova-migrate help"
