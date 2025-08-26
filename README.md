# Linux Hardening Starter
Playbook semplice e prudente per mettere in sicurezza un host Linux (Debian/Ubuntu-like) senza rischiare il lockout.

## Cosa fa
- Backup delle configurazioni modificate
- SSH hardening (porta invariata)
- UFW con regole minime e rate limiting
- Fail2ban (jail sshd)
- auditd base

## Uso
```bash
sudo bash scripts/harden.sh
sudo bash scripts/rollback.sh
