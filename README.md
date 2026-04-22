# Linux Hardening Starter

Playbook semplice e prudente per mettere in sicurezza un host Linux Debian/Ubuntu-like senza aumentare inutilmente il rischio di lockout.

## Obiettivo

Questo repository serve a mostrare un approccio operativo e conservativo all'hardening iniziale di un host Linux, con attenzione a backup, rollback e modifiche graduali.

## Cosa fa

- backup delle configurazioni modificate
- SSH hardening senza cambiare la porta in modo aggressivo
- UFW con regole minime e rate limiting
- Fail2ban con jail `sshd`
- configurazione base di `auditd`

## Uso

```bash
sudo bash scripts/harden.sh
sudo bash scripts/rollback.sh
```

## Perche e utile nel profilo

Questo repository aiuta a rappresentare il lato pratico del mio lavoro: non solo analisi e report, ma anche workflow tecnici difensivi orientati alla sicurezza di base e alla riduzione del rischio operativo.

## Contesto

Pensato per laboratorio, test controllati e ambienti autorizzati. Prima di ogni utilizzo e importante valutare compatibilita, accesso remoto e finestre di intervento.

## Portfolio

Per una vista piu ampia dei repository orientati a strumenti e workflow vedi:
- [Technical Tooling](https://github.com/AndrewG83-sdt/cerberussec-site/blob/main/TOOLING.md)
- [cerberussec-site](https://github.com/AndrewG83-sdt/cerberussec-site)
