# AI TradeMaestro - Guida al Setup

## Prerequisiti di Sistema

### Software Richiesto

#### Obbligatori
- **Node.js**: Versione 18.0.0 o superiore
- **npm**: Versione 8.0.0 o superiore (incluso con Node.js)
- **Python**: Versione 3.9.0 o superiore
- **Docker**: Versione 20.10.0 o superiore
- **Docker Compose**: Versione 2.0.0 o superiore

#### Raccomandati
- **Git**: Per il controllo versione
- **VS Code**: Con estensioni per TypeScript, Python, Docker
- **Postman**: Per testare le API
- **PostgreSQL Client**: pgAdmin o DBeaver per gestione database

### Verifica Prerequisiti

Esegui questi comandi per verificare che tutto sia installato correttamente:

```bash
# Verifica Node.js e npm
node --version  # Dovrebbe essere >= 18.0.0
npm --version   # Dovrebbe essere >= 8.0.0

# Verifica Python
python --version  # Dovrebbe essere >= 3.9.0
# o su alcuni sistemi
python3 --version

# Verifica Docker
docker --version         # Dovrebbe essere >= 20.10.0
docker-compose --version # Dovrebbe essere >= 2.0.0
```

## Setup del Progetto

### 1. Clone del Repository

```bash
# Clona il repository
git clone <repository-url>
cd ai-trade-video-social

# Verifica la struttura
ls -la
```

### 2. Configurazione Environment

#### 2.1 Configurazione Globale

Il file `config.json` nella root contiene le configurazioni principali:

```json
{
  "app": {
    "name": "AI TradeMaestro",
    "version": "1.0.0",
    "description": "Modern AI Trading Platform"
  },
  "urls": {
    "frontend": {
      "dev": "http://localhost:3000",
      "production": "https://aitrademaestro.com"
    },
    "backend": {
      "dev": "http://localhost:8000",
      "production": "https://api.aitrademaestro.com"
    }
  },
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "aitrademaestro",
    "user": "postgres",
    "password": "password"
  },
  "redis": {
    "host": "localhost",
    "port": 6379,
    "db": 0
  }
}
```

⚠️ **Importante**: In produzione, non utilizzare mai credenziali hardcoded. Usa variabili d'ambiente.

#### 2.2 Environment Variables

Crea un file `.env` nella directory `backend/`:

```bash
# Backend Environment Variables
cd backend
cat > .env << EOF
# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/aitrademaestro

# Redis
REDIS_URL=redis://localhost:6379/0

# Security
SECRET_KEY=your-super-secret-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Environment
ENVIRONMENT=development
DEBUG=true

# CORS
CORS_ORIGINS=["http://localhost:3000", "http://127.0.0.1:3000"]
EOF
```

### 3. Setup Backend (FastAPI)

#### 3.1 Creazione Virtual Environment

```bash
cd backend

# Crea virtual environment
python -m venv venv

# Attiva virtual environment
# Su Windows:
venv\Scripts\activate
# Su macOS/Linux:
source venv/bin/activate

# Verifica attivazione (dovrebbe mostrare (venv) nel prompt)
which python  # Dovrebbe puntare al virtual environment
```

#### 3.2 Installazione Dipendenze

```bash
# Assicurati di essere nella directory backend con venv attivo
pip install --upgrade pip
pip install -r requirements.txt

# Verifica installazione
pip list | grep fastapi
pip list | grep uvicorn
```

#### 3.3 Setup Database (Opzionale per Sviluppo Base)

Se vuoi utilizzare PostgreSQL invece del sistema semplificato:

```bash
# Installa PostgreSQL (esempio per Ubuntu/Debian)
sudo apt update
sudo apt install postgresql postgresql-contrib

# Crea database
sudo -u postgres createdb aitrademaestro

# Crea utente
sudo -u postgres psql -c "CREATE USER postgres WITH PASSWORD 'password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE aitrademaestro TO postgres;"
```

#### 3.4 Inizializzazione Database (con Alembic)

```bash
# Solo se usi PostgreSQL, genera migration iniziale
alembic revision --autogenerate -m "Initial migration"

# Applica migration
alembic upgrade head
```

### 4. Setup Frontend (React)

#### 4.1 Installazione Dipendenze

```bash
cd frontend

# Installa dipendenze
npm install

# Verifica installazione
npm list react
npm list vite
```

#### 4.2 Configurazione Environment

Crea un file `.env` nella directory `frontend/`:

```bash
cat > .env << EOF
# API Configuration
VITE_API_BASE_URL=http://localhost:8000
VITE_API_TIMEOUT=10000

# Environment
VITE_ENVIRONMENT=development
VITE_DEBUG=true

# Features
VITE_ENABLE_DEV_TOOLS=true
VITE_ENABLE_I18N=true
EOF
```

### 5. Setup Docker (Opzionale)

#### 5.1 Build delle Immagini

```bash
# Dalla root del progetto
docker-compose -f docker-compose.dev.yml build

# Verifica immagini create
docker images | grep ai-trademaestro
```

#### 5.2 Setup Nginx (per Produzione)

```bash
# Crea directory per Nginx
mkdir -p nginx/ssl

# Configurazione base Nginx
cat > nginx/nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }

    upstream backend {
        server backend:8000;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://frontend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }

        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
}
EOF
```

## Verifica Setup

### 1. Test Backend

```bash
cd backend

# Attiva virtual environment se non già attivo
source venv/bin/activate  # macOS/Linux
# o
venv\Scripts\activate     # Windows

# Avvia server di sviluppo
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000

# In un altro terminale, testa l'API
curl http://localhost:8000/
curl http://localhost:8000/health
```

Output atteso:
```json
{"message": "AI TradeMaestro API", "version": "1.0.0"}
{"status": "healthy", "service": "AI TradeMaestro API"}
```

### 2. Test Frontend

```bash
cd frontend

# Avvia server di sviluppo
npm run dev

# Il frontend dovrebbe essere disponibile su http://localhost:3000
```

### 3. Test Integrazione

Con entrambi i servizi attivi:

1. Apri http://localhost:3000 nel browser
2. L'applicazione dovrebbe caricarsi senza errori
3. Apri Developer Tools e verifica che non ci siano errori nella console
4. Le chiamate API dovrebbero funzionare correttamente

## Configurazioni IDE

### Visual Studio Code

Installa le seguenti estensioni:

```json
{
  "recommendations": [
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-docker",
    "ms-vscode.vscode-json",
    "ms-vscode.vscode-yaml",
    "esbenp.prettier-vscode",
    "ms-python.flake8",
    "ms-python.black-formatter"
  ]
}
```

Configurazione workspace (`.vscode/settings.json`):

```json
{
  "python.defaultInterpreterPath": "./backend/venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "tailwindCSS.experimental.configFile": "./frontend/tailwind.config.js"
}
```

### PyCharm (Opzionale)

1. Apri il progetto
2. Configura Python Interpreter: `backend/venv/bin/python`
3. Marca `backend` come Sources Root
4. Configura Run Configuration per FastAPI
5. Abilita Docker support

## Troubleshooting

### Problemi Comuni

#### 1. Errore Port già in uso

```bash
# Trova processi che usano le porte 3000 e 8000
netstat -tlnp | grep :3000
netstat -tlnp | grep :8000

# Termina processo se necessario
kill -9 <PID>
```

#### 2. Problemi Virtual Environment Python

```bash
# Ricrea virtual environment
rm -rf backend/venv
cd backend
python -m venv venv
source venv/bin/activate  # o venv\Scripts\activate su Windows
pip install -r requirements.txt
```

#### 3. Problemi Dipendenze Node.js

```bash
cd frontend

# Pulisci cache npm
npm cache clean --force

# Rimuovi node_modules e reinstalla
rm -rf node_modules package-lock.json
npm install
```

#### 4. Problemi CORS

Verifica che nel file `backend/main.py` gli origins siano configurati correttamente:

```python
origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    # Aggiungi altri domini se necessario
]
```

#### 5. Problemi Database Connection

```bash
# Verifica che PostgreSQL sia attivo
sudo systemctl status postgresql  # Linux
brew services list | grep postgresql  # macOS

# Testa connessione
psql -h localhost -U postgres -d aitrademaestro
```

### Logs e Debug

#### Backend Logs

```bash
# Avvia con debug verboso
cd backend
python -m uvicorn main:app --reload --log-level debug
```

#### Frontend Logs

```bash
# Avvia con debug
cd frontend
npm run dev -- --debug
```

#### Docker Logs

```bash
# Visualizza logs dei container
docker-compose logs -f backend
docker-compose logs -f frontend
```

## Prossimi Passi

Dopo aver completato il setup:

1. Leggi la [Guida allo Sviluppo](DEVELOPMENT.md)
2. Familiarizza con l'[Architettura](ARCHITECTURE.md)
3. Consulta la [Documentazione API](API.md)
4. Per il deployment, segui la [Guida al Deployment](DEPLOYMENT.md)

## Supporto

Se incontri problemi durante il setup:

1. Verifica che tutti i prerequisiti siano installati correttamente
2. Controlla i logs per errori specifici
3. Consulta la sezione Troubleshooting
4. Verifica la documentazione delle dipendenze specifiche