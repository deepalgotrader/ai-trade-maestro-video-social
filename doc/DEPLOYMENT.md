# 🚀 Guida al Deployment in Produzione

Questa guida ti aiuterà a deployare **AI TradeMaestro** in produzione sul tuo VPS con il dominio **aitrademaestro.ddns.net**.

## 📋 Prerequisiti

1. **VPS/Server** con accesso root o sudo
2. **Dominio DDNS configurato**: aitrademaestro.ddns.net
3. **Porte aperte**: 80 (HTTP) e 443 (HTTPS)
4. **DNS puntato correttamente** al tuo VPS

## 🌐 Passo 1: Configurazione DDNS

Il dominio **aitrademaestro.ddns.net** è un dominio dinamico (DDNS). Assicurati che:

1. Il tuo servizio DDNS (es. No-IP, DuckDNS, ecc.) sia configurato
2. Il dominio punti all'IP pubblico del tuo VPS
3. Se il tuo IP cambia, il servizio DDNS lo aggiorni automaticamente

**Verifica che il dominio punti al tuo VPS:**
```bash
# Dovrebbe restituire l'IP pubblico del tuo VPS
dig aitrademaestro.ddns.net

# Oppure
nslookup aitrademaestro.ddns.net
```

## 🔧 Passo 2: Setup Iniziale del Server

### 2.1 - Accedi al VPS

```bash
# Connettiti al tuo VPS via SSH
ssh root@IP_DEL_TUO_VPS

# Oppure con un utente specifico
ssh utente@IP_DEL_TUO_VPS
```

### 2.2 - Clona il Repository

```bash
# Crea la directory per le applicazioni web
mkdir -p ~/web_apps
cd ~/web_apps

# Clona il repository
git clone https://github.com/your-username/ai-trade-maestro-video-social.git
cd ai-trade-maestro-video-social
```

### 2.3 - Installa Dipendenze Automaticamente

Lo script `setup.sh` installerà automaticamente **TUTTE** le dipendenze necessarie:
- ✅ Docker e Docker Compose
- ✅ Node.js e npm
- ✅ Python 3 e pip
- ✅ Dipendenze di sistema (curl, wget, gnupg2, ecc.)

```bash
# Rendi eseguibile lo script
chmod +x scripts/dev/setup.sh

# Esegui lo script di setup
./scripts/dev/setup.sh
```

**Lo script farà automaticamente:**
1. Rileva il sistema operativo (Ubuntu/Debian/CentOS)
2. Aggiorna i pacchetti di sistema
3. Installa Docker se non presente
4. Installa Docker Compose se non presente
5. Installa Node.js LTS se non presente
6. Installa Python 3 e pip se non presenti
7. Installa dipendenze frontend (npm install)
8. Installa dipendenze backend (pip install)
9. Builda le immagini Docker per sviluppo

**⏱️ Tempo stimato:** 5-15 minuti (dipende dalla connessione e dalle dipendenze già presenti)

### 2.4 - Verifica l'Installazione

Dopo il setup, verifica che tutto sia installato correttamente:

```bash
# Verifica Docker
docker --version
# Output atteso: Docker version 24.x.x

# Verifica Docker Compose
docker-compose --version
# Output atteso: Docker Compose version v2.x.x

# Verifica Node.js
node --version
# Output atteso: v20.x.x (o versione LTS)

# Verifica npm
npm --version
# Output atteso: 10.x.x

# Verifica Python
python3 --version
# Output atteso: Python 3.x.x

# Verifica pip
pip3 --version
# Output atteso: pip 23.x.x
```

**⚠️ Nota Importante:** Se hai installato Docker per la prima volta, potrebbe essere necessario:

```bash
# Logout e login per applicare i permessi del gruppo Docker
exit

# Riconnettiti
ssh root@IP_DEL_TUO_VPS

# Oppure usa questo comando per aggiornare i gruppi
newgrp docker
```

## 🔐 Passo 3: Configurazione Variabili d'Ambiente

### 3.1 - Genera Password Sicure

Prima di creare il file `.env.production`, genera tutte le password necessarie. Sul VPS esegui:

```bash
# Genera SECRET_KEY (64 caratteri)
echo "SECRET_KEY=$(openssl rand -hex 32)"

# Genera password PostgreSQL
echo "POSTGRES_PASSWORD=$(openssl rand -base64 24)"

# Genera password Redis
echo "REDIS_PASSWORD=$(openssl rand -base64 24)"
```

**Copia questi valori** - ti serviranno nel prossimo step!

### 3.2 - Crea il File .env.production

```bash
# Vai nella directory del progetto
cd ~/web_apps/ai-trade-maestro-video-social

# Copia il template
cp .env.production.example .env.production

# Modifica il file
nano .env.production
```

### 3.3 - Configura le Variabili

Inserisci i valori generati nel file `.env.production`:

```env
# Database Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=K9m2PqXz4Lw8Rt5Nh3Vb2Qw9  # ← Incolla la password generata
POSTGRES_DB=aitrademaestro

# Redis Configuration
REDIS_PASSWORD=Yz8Jn5Vb2Qw9Fd6Mh1Kp3Rs7  # ← Incolla la password generata

# Backend Configuration
SECRET_KEY=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2  # ← Incolla la chiave generata (minimo 64 caratteri)
ENVIRONMENT=production

# SSL Configuration
SSL_EMAIL=tua-email-reale@gmail.com  # ← Inserisci la TUA email (per notifiche Let's Encrypt)
```

**📋 Spiegazione delle Variabili:**

| Variabile | Descrizione | Esempio |
|-----------|-------------|---------|
| `POSTGRES_USER` | Username database (lascia `postgres`) | `postgres` |
| `POSTGRES_PASSWORD` | Password database (24+ caratteri random) | `K9m2PqXz4Lw8Rt5Nh3Vb2Qw9` |
| `POSTGRES_DB` | Nome database (lascia `aitrademaestro`) | `aitrademaestro` |
| `REDIS_PASSWORD` | Password Redis (24+ caratteri random, DIVERSA da Postgres) | `Yz8Jn5Vb2Qw9Fd6Mh1Kp3Rs7` |
| `SECRET_KEY` | Chiave segreta backend (64+ caratteri random) | `a1b2c3...` |
| `ENVIRONMENT` | Ambiente di esecuzione (lascia `production`) | `production` |
| `SSL_EMAIL` | La tua email reale per certificati SSL | `tua@email.com` |

**⚠️ Regole di Sicurezza:**

1. ✅ **Usa password generate** - NON usare password semplici come `password123`
2. ✅ **Password diverse** - Database e Redis devono avere password DIVERSE
3. ✅ **SECRET_KEY lungo** - Minimo 64 caratteri random
4. ✅ **Email reale** - Riceverai notifiche importanti da Let's Encrypt
5. ✅ **Salva in sicurezza** - Usa un password manager (Bitwarden, 1Password, LastPass)
6. ❌ **MAI committare** - Il file `.env.production` è già nel `.gitignore`

**Salva il file:**
- Premi `Ctrl+O` per salvare
- Premi `Enter` per confermare
- Premi `Ctrl+X` per uscire

### 3.4 - Verifica il File

```bash
# Verifica che il file esista e contenga i valori
cat .env.production

# Assicurati che non ci siano spazi extra o errori di sintassi
```

## 🚀 Passo 4: Deploy dell'Applicazione

### 4.1 - Prepara gli Script

```bash
# Assicurati di essere nella directory del progetto
cd ~/web_apps/ai-trade-maestro-video-social

# Rendi eseguibili TUTTI gli script di produzione
chmod +x scripts/prod/*.sh
```

### 4.2 - Esegui il Deploy Automatico

```bash
# Lancia il deployment completo
./scripts/prod/deploy.sh
```

**🔄 Cosa fa lo script di deployment:**

Lo script `deploy.sh` esegue automaticamente tutti questi step in sequenza:

1. ✅ **Verifica `.env.production`** - Controlla che il file di configurazione esista
2. ✅ **Ferma servizi esistenti** - Se ci sono deployment precedenti
3. ✅ **Pull da Git (opzionale)** - Scarica gli ultimi aggiornamenti dal repository
4. ✅ **Build immagini Docker** - Compila le immagini di backend e frontend
5. ✅ **Avvia servizi temporanei** - Parte con configurazione HTTP (senza SSL)
6. ✅ **Ottiene certificato SSL** - Richiede certificato da Let's Encrypt per HTTPS
7. ✅ **Configura HTTPS** - Attiva la configurazione SSL su Nginx
8. ✅ **Riavvia Nginx** - Applica la configurazione HTTPS
9. ✅ **Esegue migrazioni database** - Crea/aggiorna le tabelle PostgreSQL
10. ✅ **Verifica stato** - Controlla che tutti i container siano running

**⏱️ Tempo stimato:** 5-10 minuti

**📺 Output Atteso:**

Durante il deployment vedrai output simile a:

```
==========================================
AI TradeMaestro - Production Deployment
==========================================

>>> Stopping existing services...
>>> Building Docker images...
>>> Starting services (without SSL initially)...
>>> Obtaining SSL certificate...
Requesting SSL certificate for aitrademaestro.ddns.net...
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/aitrademaestro.ddns.net/fullchain.pem
>>> Switching to SSL configuration...
>>> Running database migrations...
INFO  [alembic.runtime.migration] Running upgrade -> head

==========================================
Deployment Completed Successfully!
==========================================

Your application is now live at:
  https://aitrademaestro.ddns.net
```

### 4.3 - Risoluzione Problemi Durante il Deploy

**❌ Errore: "Failed to obtain SSL certificate"**

Possibili cause:
- Il dominio DDNS non punta al VPS
- Le porte 80/443 non sono aperte
- Nginx non è accessibile dall'esterno

**Soluzione:**
```bash
# 1. Verifica il DNS
dig aitrademaestro.ddns.net
# Deve mostrare l'IP del tuo VPS

# 2. Verifica le porte
sudo netstat -tlnp | grep -E ':(80|443)'

# 3. Testa l'accesso HTTP
curl -I http://localhost

# 4. Controlla i log
docker logs aitrademaestro-nginx
```

**❌ Errore: "Database connection failed"**

```bash
# Verifica che PostgreSQL sia running
docker ps | grep postgres

# Controlla i log del database
docker logs aitrademaestro-postgres

# Verifica le credenziali in .env.production
cat .env.production | grep POSTGRES
```

**❌ Errore: "Port already in use"**

```bash
# Trova quale processo usa la porta 80 o 443
sudo lsof -i :80
sudo lsof -i :443

# Ferma il processo conflittuale (es. Apache)
sudo systemctl stop apache2
sudo systemctl disable apache2
```

## 🎉 Passo 5: Verifica

Dopo il deployment, verifica che tutto funzioni:

**Nel browser:**
- Frontend: https://aitrademaestro.ddns.net
- Backend API: https://aitrademaestro.ddns.net/api
- Documentazione API: https://aitrademaestro.ddns.net/docs

**Verifica i servizi:**
```bash
# Controlla che tutti i container siano attivi
docker ps

# Visualizza i log
./scripts/prod/logs.sh
```

## 🔄 Comandi Utili

### Gestione Servizi

```bash
# Avvia i servizi
./scripts/prod/start.sh

# Ferma i servizi
./scripts/prod/stop.sh

# Riavvia i servizi
./scripts/prod/restart.sh

# Visualizza i log in tempo reale
./scripts/prod/logs.sh
```

### Aggiornamenti

```bash
# Per aggiornare l'applicazione
git pull origin main
./scripts/prod/deploy.sh
```

### Backup Database

```bash
# Backup del database
docker exec aitrademaestro-postgres pg_dump -U postgres aitrademaestro > backup_$(date +%Y%m%d).sql

# Ripristino del database
docker exec -i aitrademaestro-postgres psql -U postgres aitrademaestro < backup_20241029.sql
```

## 🔒 Passo 6: Configurazione Sicurezza

### 6.1 - Configura il Firewall (UFW)

**⚠️ IMPORTANTE:** Configura SSH PRIMA di abilitare il firewall, altrimenti potresti perdere l'accesso!

```bash
# Verifica lo stato attuale
sudo ufw status

# Permetti SSH (IMPORTANTE! Fallo PRIMA di abilitare UFW!)
sudo ufw allow 22/tcp

# Permetti HTTP (per Let's Encrypt)
sudo ufw allow 80/tcp

# Permetti HTTPS (per traffico SSL)
sudo ufw allow 443/tcp

# Abilita il firewall
sudo ufw enable

# Verifica le regole
sudo ufw status verbose
```

**Output atteso:**
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
```

### 6.2 - Rinnovo Automatico Certificati SSL

I certificati SSL di Let's Encrypt sono validi per **90 giorni** e si rinnovano **automaticamente**.

Il container `certbot` controlla ogni 12 ore se i certificati devono essere rinnovati.

**Per verificare lo stato dei certificati:**

```bash
# Visualizza informazioni sui certificati
docker-compose -f docker-compose.prod.yml run --rm certbot certificates
```

**Per forzare un rinnovo manuale:**

```bash
# Rinnova i certificati
docker-compose -f docker-compose.prod.yml run --rm certbot renew

# Riavvia Nginx per caricare i nuovi certificati
docker-compose -f docker-compose.prod.yml restart nginx
```

### 6.3 - Best Practices Sicurezza

**✅ Raccomandazioni:**

1. **Cambia la porta SSH (opzionale ma consigliato):**
```bash
sudo nano /etc/ssh/sshd_config
# Cambia: Port 22 → Port 2222
sudo systemctl restart sshd
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp
```

2. **Disabilita login root via SSH:**
```bash
sudo nano /etc/ssh/sshd_config
# Cambia: PermitRootLogin yes → PermitRootLogin no
sudo systemctl restart sshd
```

3. **Usa autenticazione con chiave SSH invece di password:**
```bash
# Sul tuo computer locale
ssh-keygen -t ed25519 -C "tua-email@example.com"
ssh-copy-id utente@IP_VPS
```

4. **Installa fail2ban per protezione brute-force:**
```bash
sudo apt-get install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

5. **Backup regolari del database:**
```bash
# Crea uno script di backup
nano ~/backup-db.sh
```

Inserisci questo contenuto:
```bash
#!/bin/bash
BACKUP_DIR=~/backups
mkdir -p $BACKUP_DIR
DATE=$(date +%Y%m%d_%H%M%S)
docker exec aitrademaestro-postgres pg_dump -U postgres aitrademaestro | gzip > $BACKUP_DIR/backup_$DATE.sql.gz
# Mantieni solo gli ultimi 7 backup
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete
```

```bash
# Rendi eseguibile
chmod +x ~/backup-db.sh

# Aggiungi al crontab per backup giornaliero alle 2:00 AM
crontab -e
# Aggiungi: 0 2 * * * /root/backup-db.sh
```

## 🐛 Troubleshooting

### Certificato SSL non ottenuto

**Problema:** `Failed to obtain SSL certificate`

**Soluzioni:**
1. Verifica che il dominio DDNS punti al tuo VPS: `dig aitrademaestro.ddns.net`
2. Assicurati che le porte 80 e 443 siano aperte: `sudo ufw status`
3. Controlla i log di nginx: `docker logs aitrademaestro-nginx`
4. Controlla i log di certbot: `docker logs aitrademaestro-certbot`

### Servizi non raggiungibili

**Problema:** L'applicazione non è accessibile dall'esterno

**Soluzioni:**
1. Verifica che i container siano attivi: `docker ps`
2. Controlla i log: `./scripts/prod/logs.sh`
3. Verifica il firewall: `sudo ufw status`
4. Testa la connettività: `curl -I http://localhost`

### Database connection error

**Problema:** Backend non riesce a connettersi al database

**Soluzioni:**
1. Verifica che PostgreSQL sia attivo: `docker ps | grep postgres`
2. Controlla le credenziali in `.env.production`
3. Verifica i log del backend: `docker logs aitrademaestro-backend`
4. Controlla la connessione: `docker exec aitrademaestro-postgres pg_isready`

## 📊 Monitoraggio e Manutenzione

### Monitoraggio Risorse

**Controlla CPU, RAM e Network dei container:**

```bash
# Statistiche in tempo reale di tutti i container
docker stats

# Output esempio:
# CONTAINER ID   NAME                    CPU %   MEM USAGE / LIMIT     MEM %
# abc123         aitrademaestro-nginx    0.5%    50MiB / 2GiB         2.5%
# def456         aitrademaestro-backend  5.2%    300MiB / 2GiB       15.0%
# ...
```

**Controlla spazio disco:**

```bash
# Spazio disco generale
df -h

# Spazio usato da Docker
docker system df

# Pulisci risorse Docker inutilizzate
docker system prune -a
```

### Visualizza Log

**Log di tutti i servizi:**

```bash
# Log in tempo reale di tutti i container
./scripts/prod/logs.sh

# Oppure
docker-compose -f docker-compose.prod.yml logs -f
```

**Log di servizi specifici:**

```bash
# Solo backend
docker logs aitrademaestro-backend -f

# Solo frontend
docker logs aitrademaestro-frontend -f

# Solo nginx (errori di connessione, SSL, ecc.)
docker logs aitrademaestro-nginx -f

# Solo database
docker logs aitrademaestro-postgres -f

# Ultimi 100 log del backend
docker logs aitrademaestro-backend --tail 100

# Log con timestamp
docker logs aitrademaestro-backend -f --timestamps
```

### Health Check

**Verifica stato dei servizi:**

```bash
# Lista di tutti i container in esecuzione
docker ps

# Verifica salute del database
docker exec aitrademaestro-postgres pg_isready -U postgres

# Verifica Redis
docker exec aitrademaestro-redis redis-cli ping
# Output atteso: PONG

# Test endpoint backend
curl https://aitrademaestro.ddns.net/api/health

# Test frontend
curl -I https://aitrademaestro.ddns.net
```

### Restart Servizi

```bash
# Riavvia tutti i servizi
./scripts/prod/restart.sh

# Riavvia solo un servizio specifico
docker-compose -f docker-compose.prod.yml restart backend
docker-compose -f docker-compose.prod.yml restart frontend
docker-compose -f docker-compose.prod.yml restart nginx
```

## 🔄 Aggiornamenti e Manutenzione

### Aggiornare l'Applicazione

Quando ci sono nuove versioni del codice:

```bash
# 1. Connettiti al VPS
ssh root@IP_VPS
cd ~/web_apps/ai-trade-maestro-video-social

# 2. Backup del database (IMPORTANTE!)
docker exec aitrademaestro-postgres pg_dump -U postgres aitrademaestro | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz

# 3. Scarica gli aggiornamenti da Git
git pull origin main

# 4. Ricostruisci e rideploya
./scripts/prod/deploy.sh
```

### Rollback (Torna alla Versione Precedente)

Se qualcosa va storto dopo un aggiornamento:

```bash
# 1. Vedi la lista dei commit
git log --oneline -10

# 2. Torna al commit precedente
git checkout <commit-hash>

# 3. Rideploya
./scripts/prod/deploy.sh

# 4. Se il rollback è definitivo
git reset --hard <commit-hash>
git push origin main --force  # SOLO se sei sicuro!
```

### Backup e Restore

**Backup Manuale del Database:**

```bash
# Backup compresso
docker exec aitrademaestro-postgres pg_dump -U postgres aitrademaestro | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz

# Backup normale (non compresso)
docker exec aitrademaestro-postgres pg_dump -U postgres aitrademaestro > backup.sql

# Download backup sul tuo computer locale
scp root@IP_VPS:~/backup_*.sql.gz ~/Desktop/
```

**Restore del Database:**

```bash
# Da file compresso
gunzip < backup_20241029_120000.sql.gz | docker exec -i aitrademaestro-postgres psql -U postgres aitrademaestro

# Da file normale
docker exec -i aitrademaestro-postgres psql -U postgres aitrademaestro < backup.sql

# ATTENZIONE: Questo sovrascrive tutti i dati esistenti!
```

**Backup dei file di configurazione:**

```bash
# Backup .env.production (contiene password!)
cp .env.production .env.production.backup_$(date +%Y%m%d)

# Backup delle configurazioni nginx
tar -czf nginx_backup_$(date +%Y%m%d).tar.gz nginx/

# Download sul computer locale
scp root@IP_VPS:~/.env.production.backup_* ~/Desktop/
```

## 📞 Supporto e Troubleshooting

### Checklist Diagnostica

Se l'applicazione non funziona, segui questa checklist:

**1. Verifica che i container siano running:**
```bash
docker ps
# Dovresti vedere 6 container: nginx, certbot, postgres, redis, backend, frontend
```

**2. Controlla i log per errori:**
```bash
./scripts/prod/logs.sh
# Premi Ctrl+C per uscire
```

**3. Verifica la connessione al database:**
```bash
docker exec aitrademaestro-postgres pg_isready -U postgres
# Output atteso: accepting connections
```

**4. Testa il backend:**
```bash
curl https://aitrademaestro.ddns.net/api/health
# Dovrebbe rispondere con status 200 OK
```

**5. Verifica DNS:**
```bash
dig aitrademaestro.ddns.net
# Deve mostrare l'IP del tuo VPS
```

**6. Controlla il firewall:**
```bash
sudo ufw status
# Porte 80 e 443 devono essere ALLOW
```

**7. Verifica certificato SSL:**
```bash
docker-compose -f docker-compose.prod.yml run --rm certbot certificates
# Mostra info sui certificati attivi
```

### Comandi Utili Rapidi

```bash
# Ferma tutto
./scripts/prod/stop.sh

# Avvia tutto
./scripts/prod/start.sh

# Riavvia tutto
./scripts/prod/restart.sh

# Vedi i log
./scripts/prod/logs.sh

# Controlla risorse
docker stats

# Controlla spazio disco
df -h

# Pulisci Docker (libera spazio)
docker system prune -a

# Accedi al database
docker exec -it aitrademaestro-postgres psql -U postgres aitrademaestro

# Accedi a Redis
docker exec -it aitrademaestro-redis redis-cli

# Vedi variabili d'ambiente
cat .env.production
```

### Contatti e Risorse

- **Repository GitHub:** [Link al tuo repo]
- **Documentazione Docker:** https://docs.docker.com/
- **Let's Encrypt:** https://letsencrypt.org/docs/
- **Nginx Docs:** https://nginx.org/en/docs/

---

## ✅ Riepilogo Finale

**🎯 Per deployare da zero:**

```bash
# 1. Configura DNS → aitrademaestro.ddns.net punta al tuo VPS
# 2. SSH nel VPS
ssh root@IP_VPS

# 3. Clona e setup
cd ~/web_apps
git clone <repo-url> ai-trade-maestro-video-social
cd ai-trade-maestro-video-social
./scripts/dev/setup.sh

# 4. Configura variabili
cp .env.production.example .env.production
nano .env.production  # Inserisci password generate

# 5. Deploy!
./scripts/prod/deploy.sh

# 6. Configura firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

**🚀 L'app sarà live su:** https://aitrademaestro.ddns.net

---

**⚠️ Note Importanti:**
- ✅ Fai backup regolari del database
- ✅ Monitora i log per errori
- ✅ Tieni aggiornato il sistema operativo: `sudo apt-get update && sudo apt-get upgrade`
- ✅ I certificati SSL si rinnovano automaticamente ogni 90 giorni
- ✅ Salva le password in un password manager
- ❌ MAI committare `.env.production` su Git