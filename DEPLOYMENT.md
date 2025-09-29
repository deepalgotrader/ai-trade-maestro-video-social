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

Sul tuo VPS, clona il repository e installa le dipendenze:

```bash
# Clona il repository
git clone https://github.com/your-username/ai-trade-maestro-video-social.git
cd ai-trade-maestro-video-social

# Esegui lo script di setup (installa Docker, Node.js, Python, ecc.)
chmod +x scripts/dev/setup.sh
./scripts/dev/setup.sh
```

## 🔐 Passo 3: Configurazione Variabili d'Ambiente

Crea il file `.env.production` con le tue credenziali:

```bash
# Copia il file di esempio
cp .env.production.example .env.production

# Modifica il file con i tuoi valori
nano .env.production
```

**Configura queste variabili (IMPORTANTE):**

```env
# Database - Usa password sicure!
POSTGRES_USER=postgres
POSTGRES_PASSWORD=TUA_PASSWORD_SICURA_QUI
POSTGRES_DB=aitrademaestro

# Redis - Usa password sicure!
REDIS_PASSWORD=TUA_PASSWORD_REDIS_QUI

# Backend - Genera una chiave segreta lunga almeno 32 caratteri
SECRET_KEY=genera_una_chiave_segreta_molto_lunga_e_casuale_qui
ENVIRONMENT=production

# SSL - Inserisci la tua email per Let's Encrypt
SSL_EMAIL=tua-email@example.com
```

**Per generare una SECRET_KEY sicura:**
```bash
openssl rand -base64 32
```

## 🚀 Passo 4: Deploy dell'Applicazione

Esegui lo script di deployment automatico:

```bash
# Rendi eseguibili gli script
chmod +x scripts/prod/*.sh

# Esegui il deployment
./scripts/prod/deploy.sh
```

Questo script farà automaticamente:
1. ✅ Build delle immagini Docker
2. ✅ Avvio dei servizi
3. ✅ Richiesta certificato SSL da Let's Encrypt
4. ✅ Configurazione HTTPS
5. ✅ Esecuzione migrazioni database

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

## 🔒 Sicurezza

### Firewall (UFW)

```bash
# Abilita il firewall
sudo ufw enable

# Permetti SSH (IMPORTANTE! Fallo prima!)
sudo ufw allow 22/tcp

# Permetti HTTP e HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Verifica lo stato
sudo ufw status
```

### Rinnovo Certificati SSL

I certificati SSL si rinnovano automaticamente. Per forzare un rinnovo:

```bash
docker-compose -f docker-compose.prod.yml run --rm certbot renew
docker-compose -f docker-compose.prod.yml restart nginx
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

## 📊 Monitoraggio

### Visualizza risorse utilizzate

```bash
# CPU e memoria dei container
docker stats

# Spazio disco
df -h

# Log specifici di un servizio
docker logs aitrademaestro-backend -f
docker logs aitrademaestro-frontend -f
docker logs aitrademaestro-nginx -f
```

## 🔄 Aggiornamenti Futuri

Per aggiornare l'applicazione con nuove versioni:

```bash
# 1. Backup del database
docker exec aitrademaestro-postgres pg_dump -U postgres aitrademaestro > backup_$(date +%Y%m%d).sql

# 2. Pull delle modifiche
git pull origin main

# 3. Ricostruzione e restart
./scripts/prod/deploy.sh
```

## 📞 Supporto

Se hai problemi, controlla:
1. I log dei container: `./scripts/prod/logs.sh`
2. Lo stato dei servizi: `docker ps -a`
3. La configurazione DNS
4. Le variabili d'ambiente in `.env.production`

---

**Nota:** Assicurati sempre di avere backup regolari del database e delle variabili d'ambiente!