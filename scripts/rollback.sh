#!/usr/bin/env bash
set -euo pipefail
LATEST_BACKUP=$(ls -1dt backup/* 2>/dev/null | head -n1 || true)
if [[ -z "$LATEST_BACKUP" ]]; then
  echo "Nessun backup trovato in backup/" >&2
  exit 1
fi
echo "[*] Ripristino da $LATEST_BACKUP"

if [[ -f "${LATEST_BACKUP}/sshd_config.bak" ]]; then
  cp -a "${LATEST_BACKUP}/sshd_config.bak" /etc/ssh/sshd_config
  systemctl reload ssh || systemctl reload sshd || true
  echo "[+] sshd_config ripristinato"
fi

if [[ -f "${LATEST_BACKUP}/jail.local.bak" ]]; then
  cp -a "${LATEST_BACKUP}/jail.local.bak" /etc/fail2ban/jail.local
  systemctl restart fail2ban || true
  echo "[+] fail2ban jail.local ripristinato"
fi

echo "[+] Ripristino completato"
