# 🚀 Quick Start - Deploy in Produzione

## Per chi ha già il sito HTTP funzionante

```bash
# Abilita HTTPS
./scripts/prod/enable-ssl.sh
```

---

## Deploy da Zero (3 comandi)

```bash
# 1. Setup (installa tutto)
./scripts/dev/setup.sh

# 2. Configura password
cp .env.production.example .env.production
nano .env.production  # Inserisci password generate con openssl

# 3. Deploy!
./scripts/prod/deploy.sh

# 4. Abilita HTTPS
./scripts/prod/enable-ssl.sh
```

---

## 📖 Documentazione Completa

Leggi la guida completa: [doc/DEPLOYMENT.md](doc/DEPLOYMENT.md)

---

## 🛠️ Script Disponibili

| Script | Quando usarlo |
|--------|---------------|
| `./scripts/prod/deploy.sh` | Deploy iniziale o aggiornamenti |
| `./scripts/prod/enable-ssl.sh` | Abilita HTTPS dopo il deploy |
| `./scripts/prod/start.sh` | Avvia i servizi |
| `./scripts/prod/stop.sh` | Ferma i servizi |
| `./scripts/prod/restart.sh` | Riavvia i servizi |
| `./scripts/prod/logs.sh` | Visualizza log |

---

## ✅ Il Sito è Live

- **HTTP:** http://aitrademaestro.ddns.net
- **HTTPS:** https://aitrademaestro.ddns.net (dopo enable-ssl.sh)

---

## 🆘 Problemi?

```bash
# Porte occupate?
./scripts/prod/fix-port-conflict.sh

# DNS non funziona?
./scripts/prod/check-dns.sh

# Pulizia completa
./scripts/prod/force-stop-and-cleanup.sh
```

---

**📚 Per maggiori dettagli:** [doc/DEPLOYMENT.md](doc/DEPLOYMENT.md)