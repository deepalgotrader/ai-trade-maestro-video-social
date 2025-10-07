# 🚀 Guida al Deployment in Produzione

Questa guida ti aiuterà a deployare **AI TradeMaestro** in produzione sul tuo VPS con il dominio **aitrademaestro.ddns.net**.

## 📋 Prerequisiti

1. **VPS/Server** con Ubuntu/Debian
2. **Dominio DDNS** configurato: aitrademaestro.ddns.net
3. **Accesso SSH** al server
4. **Porte aperte**: 80 (HTTP) e 443 (HTTPS)

---

## 🎯 Deployment Rapido (3 Comandi)

```bash
# 1. Setup iniziale (installa tutto)
./scripts/dev/setup.sh

# 2. Configura variabili d'ambiente
cp .env.production.example .env.production
nano .env.production  # Inserisci le tue password

# 3. Deploy!
./scripts/prod/deploy.sh

# 4. Abilita HTTPS
./scripts/prod/enable-ssl.sh
```

---

## 📖 Guida Completa Passo-Passo

### Passo 1: Connetti al VPS

```bash
ssh root@IP_DEL_TUO_VPS
```

### Passo 2: Clona il Repository

```bash
mkdir -p ~/web_apps
cd ~/web_apps
git clone https://github.com/your-username/ai-trade-maestro-video-social.git
cd ai-trade-maestro-video-social
```

### Passo 3: Setup Automatico

Lo script installerà automaticamente:
- Docker & Docker Compose
- Node.js & npm
- Python 3 & pip
- Tutte le dipendenze

```bash
chmod +x scripts/dev/setup.sh
./scripts/dev/setup.sh
```

**⏱️ Tempo stimato:** 5-10 minuti

### Passo 4: Configura Variabili d'Ambiente

```bash
# Copia il template
cp .env.production.example .env.production

# Genera password sicure
echo "SECRET_KEY=$(openssl rand -hex 32)"
echo "POSTGRES_PASSWORD=$(openssl rand -base64 24)"
echo "REDIS_PASSWORD=$(openssl rand -base64 24)"

# Modifica il file con le password generate
nano .env.production
```

**File .env.production:**
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=K9m2PqXz4Lw8Rt5Nh3  # ← Password generata
POSTGRES_DB=aitrademaestro

REDIS_PASSWORD=Yz8Jn5Vb2Qw9Fd6  # ← Password generata

SECRET_KEY=a1b2c3d4e5f6g7h8i9j0...  # ← 64 caratteri random
ENVIRONMENT=production

SSL_EMAIL=tua-email@example.com  # ← La tua email reale
```

### Passo 5: Deploy dell'Applicazione

```bash
./scripts/prod/deploy.sh
```

**Cosa fa lo script:**
1. ✅ Build delle immagini Docker
2. ✅ Avvia tutti i servizi
3. ✅ Esegue migrazioni database
4. ✅ Testa che HTTP funzioni

**Output atteso:**
```
========================================
Deployment Completed!
========================================

Your application is accessible at:
  http://aitrademaestro.ddns.net

📌 Next step: Enable HTTPS
  Run: ./scripts/prod/enable-ssl.sh
```

### Passo 6: Abilita HTTPS (SSL)

```bash
./scripts/prod/enable-ssl.sh
```

**Cosa fa lo script:**
1. ✅ Verifica che HTTP funzioni
2. ✅ Richiede certificato SSL da Let's Encrypt
3. ✅ Configura HTTPS su Nginx
4. ✅ Testa che HTTPS funzioni

**Output atteso:**
```
========================================
SSL Enabled Successfully!
========================================

Your site is now secure:
  https://aitrademaestro.ddns.net
```

### Passo 7: Configura Firewall

```bash
# Permetti SSH (IMPORTANTE! Fallo PRIMA di abilitare UFW!)
sudo ufw allow 22/tcp

# Permetti HTTP e HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Abilita firewall
sudo ufw enable

# Verifica
sudo ufw status
```

---

## 🎉 Verifica Finale

```bash
# Verifica container running
docker ps

# Testa HTTPS
curl https://aitrademaestro.ddns.net

# Apri nel browser
# https://aitrademaestro.ddns.net
```

---

## 🛠️ Comandi Utili

### Gestione Servizi

```bash
# Avvia
./scripts/prod/start.sh

# Ferma
./scripts/prod/stop.sh

# Riavvia
./scripts/prod/restart.sh

# Log in tempo reale
./scripts/prod/logs.sh
```

### Monitoraggio

```bash
# Stato container
docker ps

# Log di un servizio specifico
docker logs aitrademaestro-backend -f
docker logs aitrademaestro-frontend -f
docker logs aitrademaestro-nginx -f

# Risorse utilizzate
docker stats

# Spazio disco
df -h
```

### Backup

```bash
# Backup database
docker exec aitrademaestro-postgres pg_dump -U postgres aitrademaestro | gzip > backup_$(date +%Y%m%d).sql.gz

# Backup .env.production
cp .env.production .env.production.backup
```

---

## 🐛 Risoluzione Problemi

### Problema: Port 80/443 già in uso

```bash
# Usa lo script automatico
./scripts/prod/fix-port-conflict.sh

# Oppure manualmente
sudo systemctl stop apache2 nginx
sudo systemctl disable apache2 nginx
```

### Problema: DNS non punta al server

```bash
# Verifica DNS
./scripts/prod/check-dns.sh

# Dovrebbe mostrare:
# ✓ DNS is correctly pointing to this server!
```

### Problema: Certificato SSL fallito

**Cause comuni:**
1. DNS non punta al server
2. Porta 80 non accessibile dall'esterno
3. Firewall blocca porta 80

**Soluzione:**
```bash
# Verifica DNS
dig aitrademaestro.ddns.net

# Verifica firewall
sudo ufw status

# Verifica che HTTP funzioni dall'esterno
curl http://aitrademaestro.ddns.net

# Riprova SSL
./scripts/prod/enable-ssl.sh
```

### Problema: 502 Bad Gateway

```bash
# Verifica log
docker logs aitrademaestro-nginx --tail 50
docker logs aitrademaestro-backend --tail 50
docker logs aitrademaestro-frontend --tail 50

# Verifica che tutti i container siano up
docker ps
```

---

## 🔄 Aggiornamenti

```bash
cd ~/web_apps/ai-trade-maestro-video-social

# Backup database
docker exec aitrademaestro-postgres pg_dump -U postgres aitrademaestro | gzip > backup_$(date +%Y%m%d).sql.gz

# Pull aggiornamenti
git pull origin main

# Rideploy
./scripts/prod/deploy.sh

# Se avevi SSL, ri-abilita
./scripts/prod/enable-ssl.sh
```

---

## 📞 Script Disponibili

| Script | Descrizione |
|--------|-------------|
| `deploy.sh` | Deploy completo dell'applicazione |
| `enable-ssl.sh` | Abilita HTTPS/SSL |
| `start.sh` | Avvia i servizi |
| `stop.sh` | Ferma i servizi |
| `restart.sh` | Riavvia i servizi |
| `logs.sh` | Visualizza log di tutti i servizi |
| `check-dns.sh` | Verifica configurazione DNS |
| `fix-port-conflict.sh` | Libera porte 80 e 443 |
| `force-stop-and-cleanup.sh` | Stop forzato e pulizia completa |

---

## ✅ Checklist Post-Deployment

- [ ] Sito accessibile su HTTPS
- [ ] Certificato SSL valido
- [ ] Tutti i container running
- [ ] Database funzionante
- [ ] Firewall configurato
- [ ] Backup automatici configurati
- [ ] Log monitorati

---

## ⚠️ Note Importanti

- ✅ Fai backup regolari del database
- ✅ Salva `.env.production` in un password manager
- ✅ I certificati SSL si rinnovano automaticamente ogni 90 giorni
- ✅ Monitora i log per errori
- ❌ MAI committare `.env.production` su Git

---

**🎉 Il tuo sito è ora live e sicuro su https://aitrademaestro.ddns.net!**