# AI TradeMaestro - Guida allo Sviluppo

## Panoramica Ambiente di Sviluppo

Questa guida ti aiuterà a configurare e utilizzare l'ambiente di sviluppo per AI TradeMaestro. Il progetto utilizza un'architettura moderna con hot reload per massimizzare la produttività degli sviluppatori.

## Avvio Rapido Sviluppo

### Metodo 1: Avvio Automatico (Raccomandato)

Dalla directory root del progetto:

```bash
# Avvia frontend e backend contemporaneamente
npm run dev
```

Questo comando:
- Avvia il backend FastAPI su `http://localhost:8000`
- Avvia il frontend React su `http://localhost:3000`
- Abilita hot reload su entrambi i servizi
- Mostra logs di entrambi i servizi in un unico terminale

### Metodo 2: Avvio Separato

Per un controllo più granulare:

```bash
# Terminale 1 - Backend
npm run dev:backend

# Terminale 2 - Frontend
npm run dev:frontend
```

### Metodo 3: Docker Development

Per un ambiente isolato:

```bash
# Avvia tutti i servizi con Docker
docker-compose -f docker-compose.dev.yml up

# Con rebuild automatico
docker-compose -f docker-compose.dev.yml up --build
```

## Workflow di Sviluppo

### 1. Setup Iniziale Giornaliero

```bash
# 1. Attiva virtual environment Python
cd backend
source venv/bin/activate  # macOS/Linux
# o
venv\Scripts\activate     # Windows

# 2. Verifica dipendenze aggiornate
cd ../frontend
npm install
cd ../backend
pip install -r requirements.txt

# 3. Avvia ambiente di sviluppo
cd ..
npm run dev
```

### 2. Struttura Tipica di Lavoro

```
┌─ Terminale 1: Ambiente di sviluppo ─┐
│ npm run dev                          │
│ [Backend + Frontend logs]            │
└─────────────────────────────────────┘

┌─ Terminale 2: Comandi di sviluppo ─┐
│ git status                          │
│ git add .                           │
│ npm run lint                        │
│ pytest                              │
└────────────────────────────────────┘

┌─ Browser: http://localhost:3000 ─┐
│ [Applicazione con hot reload]    │
└──────────────────────────────────┘
```

## Strumenti di Sviluppo

### Frontend (React + Vite)

#### Hot Reload e Fast Refresh

Vite fornisce hot reload ultra-veloce:

- **CSS/Tailwind**: Aggiornamenti istantanei senza perdere stato
- **React Components**: Fast Refresh preserva lo stato dei componenti
- **TypeScript**: Controllo tipi in tempo reale
- **Import resolution**: Path assoluti e relativi

#### Comandi Frontend

```bash
cd frontend

# Sviluppo con hot reload
npm run dev

# Build di produzione
npm run build

# Preview build produzione
npm run preview

# Linting
npm run lint

# Fix automatico linting
npm run lint -- --fix
```

#### Configurazione Browser

URL di sviluppo:
- **Frontend**: http://localhost:3000
- **API Docs**: http://localhost:8000/docs
- **API Redoc**: http://localhost:8000/redoc

Browser raccomandati con estensioni:
- **Chrome**: React Developer Tools, Redux DevTools
- **Firefox**: React Developer Tools
- **Edge**: React Developer Tools

### Backend (FastAPI + Uvicorn)

#### Auto-reload

Uvicorn monitora automaticamente:
- File Python modificati
- Riavvio automatico del server
- Preservazione della configurazione
- Hot reload delle route API

#### Comandi Backend

```bash
cd backend

# Sviluppo con auto-reload
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Con logging dettagliato
python -m uvicorn main:app --reload --log-level debug

# Solo binding locale
python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000

# Testing
pytest
pytest -v
pytest --cov=.

# Linting Python
flake8 .
black .
```

#### API Documentation

Durante lo sviluppo, FastAPI genera automaticamente:

- **Swagger UI**: http://localhost:8000/docs
  - Interfaccia interattiva per testare API
  - Documentazione automatica degli endpoint
  - Validazione in tempo reale

- **ReDoc**: http://localhost:8000/redoc
  - Documentazione più dettagliata
  - Layout più pulito per lettura

## Configurazioni Ambiente

### Variables di Environment

#### Frontend (.env)

```bash
# Development
VITE_API_BASE_URL=http://localhost:8000
VITE_ENVIRONMENT=development
VITE_DEBUG=true
VITE_ENABLE_DEV_TOOLS=true

# Features
VITE_ENABLE_I18N=true
VITE_ENABLE_MOCK_DATA=false
VITE_API_TIMEOUT=10000
```

#### Backend (.env)

```bash
# Development
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=debug

# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/aitrademaestro_dev

# Redis
REDIS_URL=redis://localhost:6379/0

# Security (dev only)
SECRET_KEY=dev-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# CORS
CORS_ORIGINS=["http://localhost:3000", "http://127.0.0.1:3000"]
```

### Hot Reload Configuration

#### Vite Configuration (vite.config.ts)

```typescript
export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 3000,
    open: true,
    hmr: {
      overlay: true
    }
  },
  build: {
    sourcemap: true
  }
})
```

#### Uvicorn Auto-reload

```python
# main.py
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        reload_dirs=["./"],
        reload_includes=["*.py"]
    )
```

## Debugging

### Frontend Debugging

#### Browser DevTools

```javascript
// Debug logging nel codice
console.log('Debug info:', data);
console.table(apiResponse);
console.group('API Call');
console.log('Request:', request);
console.log('Response:', response);
console.groupEnd();
```

#### React DevTools

1. Installa React DevTools extension
2. Apri tab "⚛️ Components"
3. Ispeziona state e props
4. Usa Profiler per performance

#### Network Debugging

```javascript
// Interceptor per debug API calls
import axios from 'axios';

axios.interceptors.request.use(request => {
  console.log('🚀 Request:', request);
  return request;
});

axios.interceptors.response.use(
  response => {
    console.log('✅ Response:', response);
    return response;
  },
  error => {
    console.error('❌ Error:', error);
    return Promise.reject(error);
  }
);
```

### Backend Debugging

#### Python Debugger

```python
# Breakpoint con pdb
import pdb; pdb.set_trace()

# Breakpoint con ipdb (più avanzato)
import ipdb; ipdb.set_trace()

# Debug logging
import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

@app.get("/debug")
async def debug_endpoint():
    logger.debug("Debug information")
    logger.info("Info message")
    logger.warning("Warning message")
    return {"debug": "enabled"}
```

#### FastAPI Debugging

```python
from fastapi import Request
import time

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    print(f"{request.method} {request.url} - {process_time:.4f}s")
    return response
```

## Testing

### Frontend Testing

```bash
cd frontend

# Unit tests con Vitest (se configurato)
npm run test

# E2E tests con Playwright (se configurato)
npm run test:e2e

# Component testing
npm run test:components
```

#### Test Structure

```typescript
// src/components/__tests__/Button.test.tsx
import { render, screen } from '@testing-library/react';
import { Button } from '../Button';

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });
});
```

### Backend Testing

```bash
cd backend

# Tutti i test
pytest

# Test con coverage
pytest --cov=.

# Test specifici
pytest tests/test_api.py

# Test con output verbose
pytest -v
```

#### Test Structure

```python
# tests/test_main.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "AI TradeMaestro API", "version": "1.0.0"}

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert "healthy" in response.json()["status"]
```

## Performance e Ottimizzazione

### Frontend Performance

#### Bundle Analysis

```bash
cd frontend

# Analizza dimensioni bundle
npm run build
npx vite-bundle-analyzer dist

# Analizza performance
npm run dev -- --profile
```

#### Performance Monitoring

```typescript
// Performance monitoring in development
if (import.meta.env.DEV) {
  const observer = new PerformanceObserver((list) => {
    list.getEntries().forEach((entry) => {
      console.log(`${entry.name}: ${entry.duration}ms`);
    });
  });
  observer.observe({ entryTypes: ['measure', 'navigation'] });
}
```

### Backend Performance

#### Profiling

```python
# cProfile per profiling
python -m cProfile -o profile.stats main.py

# line_profiler per profiling linea per linea
@profile
def expensive_function():
    # code here
    pass
```

#### Database Optimization

```python
# Query optimization logging
import logging
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

# Connection monitoring
from sqlalchemy import event
from sqlalchemy.engine import Engine

@event.listens_for(Engine, "before_cursor_execute")
def receive_before_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    print(f"Query: {statement}")
```

## Workflow Git

### Branching Strategy

```bash
# Feature development
git checkout -b feature/new-trading-algorithm
git add .
git commit -m "feat: implement new trading algorithm"
git push origin feature/new-trading-algorithm

# Bug fixes
git checkout -b fix/api-authentication-bug
git add .
git commit -m "fix: resolve API authentication issue"
git push origin fix/api-authentication-bug
```

### Commit Conventions

```bash
# Tipi di commit
feat: nuova funzionalità
fix: bug fix
docs: documentazione
style: formattazione, missing semi colons, etc
refactor: refactoring del codice
test: aggiunta test
chore: maintenance

# Esempi
git commit -m "feat: add user authentication system"
git commit -m "fix: resolve CORS issue in API"
git commit -m "docs: update README with setup instructions"
```

## Code Quality

### Linting e Formatting

#### Frontend

```bash
cd frontend

# ESLint
npm run lint
npm run lint -- --fix

# Prettier (se configurato)
npx prettier --write src/

# TypeScript checking
npx tsc --noEmit
```

#### Backend

```bash
cd backend

# Black formatting
black .

# Flake8 linting
flake8 .

# isort import sorting
isort .

# Type checking con mypy
mypy .
```

### Pre-commit Hooks

```bash
# Setup pre-commit hooks
pip install pre-commit
pre-commit install

# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 22.3.0
    hooks:
      - id: black
  - repo: https://github.com/pycqa/flake8
    rev: 4.0.1
    hooks:
      - id: flake8
```

## Troubleshooting Sviluppo

### Problemi Comuni

#### 1. Port già in uso

```bash
# Trova processi sulle porte
lsof -ti:3000 | xargs kill -9  # Frontend
lsof -ti:8000 | xargs kill -9  # Backend

# Su Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

#### 2. Cache issues

```bash
# Frontend cache clear
cd frontend
rm -rf node_modules/.vite
npm run dev

# Backend Python cache
find . -type d -name __pycache__ -delete
find . -name "*.pyc" -delete
```

#### 3. Dependency conflicts

```bash
# Frontend
cd frontend
rm -rf node_modules package-lock.json
npm install

# Backend
cd backend
pip freeze > current_deps.txt
pip uninstall -r current_deps.txt -y
pip install -r requirements.txt
```

### Performance Issues

#### 1. Slow hot reload

```bash
# Verifica file watching limits (Linux)
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Escludi node_modules da watching
# vite.config.ts
export default defineConfig({
  server: {
    watch: {
      ignored: ['**/node_modules/**']
    }
  }
})
```

#### 2. Memory issues

```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"
npm run dev

# Monitor memory usage
# Frontend
console.log(performance.memory);

# Backend
import psutil
print(f"Memory usage: {psutil.virtual_memory().percent}%")
```

## Best Practices Sviluppo

### Code Organization

```typescript
// Frontend - Feature-based structure
src/
├── components/
│   ├── ui/          # Reusable UI components
│   ├── forms/       # Form components
│   └── layout/      # Layout components
├── pages/           # Route components
├── hooks/           # Custom hooks
├── services/        # API services
├── utils/           # Utility functions
└── types/           # TypeScript types
```

```python
# Backend - Domain-driven structure
backend/
├── api/             # API endpoints
├── core/            # Core business logic
├── models/          # Database models
├── schemas/         # Pydantic schemas
├── services/        # Business services
└── utils/           # Utility functions
```

### Component Development

```typescript
// Component template
import React from 'react';
import { cn } from '../utils/cn';

interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  className?: string;
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  children,
  className,
  ...props
}) => {
  return (
    <button
      className={cn(
        'rounded font-medium transition-colors',
        {
          'bg-blue-600 text-white hover:bg-blue-700': variant === 'primary',
          'bg-gray-200 text-gray-900 hover:bg-gray-300': variant === 'secondary',
          'px-2 py-1 text-sm': size === 'sm',
          'px-4 py-2': size === 'md',
          'px-6 py-3 text-lg': size === 'lg',
        },
        className
      )}
      {...props}
    >
      {children}
    </button>
  );
};
```

### API Development

```python
# API endpoint template
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/api/users", tags=["users"])

class UserCreate(BaseModel):
    username: str
    email: str

class UserResponse(BaseModel):
    id: int
    username: str
    email: str

@router.post("/", response_model=UserResponse)
async def create_user(user: UserCreate):
    # Validation
    if not user.username:
        raise HTTPException(status_code=400, detail="Username required")

    # Business logic
    created_user = await user_service.create(user)

    return UserResponse(**created_user.dict())
```

Questa guida fornisce tutto il necessario per un workflow di sviluppo efficiente. Ricorda di mantenere sempre aggiornata la documentazione mentre sviluppi nuove funzionalità!