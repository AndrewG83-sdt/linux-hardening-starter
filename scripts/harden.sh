### `scripts/harden.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
TS="$(date +"%Y-%m-%d_%H-%M-%S")"
BACKUP_DIR="backup/${TS}"
mkdir -p "$BACKUP_DIR"

log() { echo "[*] $*"; }
ok()  { echo "[+] $*"; }
warn(){ echo "[!] $*"; }

# 1) SSH hardening (senza cambiare porta)
if systemctl status ssh >/dev/null 2>&1 || systemctl status sshd >/dev/null 2>&1; then
  SSHD="/etc/ssh/sshd_config"
  if [[ -f "$SSHD" ]]; then
    cp -a "$SSHD" "${BACKUP_DIR}/sshd_config.bak"
    log "Backup sshd_config in ${BACKUP_DIR}"
    sed -i 's/^[#]*\s*PermitRootLogin.*/PermitRootLogin prohibit-password/' "$SSHD"
    sed -i 's/^[#]*\s*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD"
    sed -i 's/^[#]*\s*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' "$SSHD"
    sed -i 's/^[#]*\s*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD"
    sed -i 's/^[#]*\s*X11Forwarding.*/X11Forwarding no/' "$SSHD"
    sed -i 's/^[#]*\s*UsePAM.*/UsePAM yes/' "$SSHD"
    if grep -Rq ".ssh/authorized_keys" /home/* 2>/dev/null || [[ -f "/root/.ssh/authorized_keys" ]]; then
      warn "Chiavi SSH trovate: puoi considerare di disabilitare la password (commento nello script)."
      # sed -i 's/^[#]*\s*PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD"
    fi
    systemctl reload ssh || systemctl reload sshd || true
    ok "SSH hardening applicato (porta invariata)"
  fi
else
  warn "Servizio SSH non rilevato, salto la sezione SSH."
fi

# 2) UFW
if ! command -v ufw >/dev/null 2>&1; then
  apt-get update -y && apt-get install -y ufw
fi
ufw allow OpenSSH || ufw allow 22/tcp
ufw limit 22/tcp
ufw default deny incoming
ufw default allow outgoing
echo "y" | ufw enable
ok "UFW attivo con regole base"

# 3) Fail2ban
if ! command -v fail2ban-client >/dev/null 2>&1; then
  apt-get install -y fail2ban
fi
mkdir -p /etc/fail2ban/jail.d
if [[ -f /etc/fail2ban/jail.local ]]; then
  cp -a /etc/fail2ban/jail.local "${BACKUP_DIR}/jail.local.bak"
fi
cat >/etc/fail2ban/jail.d/sshd.local <<'EOF'
[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600
findtime = 600
EOF
systemctl enable fail2ban && systemctl restart fail2ban
ok "Fail2ban attivo per sshd"

# 4) auditd
if ! command -v auditctl >/dev/null 2>&1; then
  apt-get install -y auditd audispd-plugins
fi
systemctl enable auditd && systemctl restart auditd
ok "auditd attivo"

echo
ok "Hardening completato. Backup in ${BACKUP_DIR}"
