# AI TradeMaestro

A modern microservices web application built with React frontend and FastAPI backend, featuring a clean interface for AI trading interactions.

## 🚀 Quick Start (< 10 minutes)

### Prerequisites
- Docker Desktop (Windows/Mac) or Docker + Docker Compose (Linux)
- Git (optional, for cloning)

### Development Setup

**Windows:**
```bash
cd scripts/dev
setup.bat
start.bat
```

**Linux/Mac:**
```bash
cd scripts/dev
chmod +x *.sh
./setup.sh
./start.sh
```

**Manual Setup:**
```bash
# Install dependencies
cd frontend && npm install
cd ../backend && pip install -r requirements.txt

# Start development environment
docker-compose -f docker-compose.dev.yml up -d
```

🌐 **Access the application:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Documentation: http://localhost:8000/docs

## 🏗️ Architecture

### Frontend (React + TypeScript)
- **Framework:** React 18 with TypeScript, Vite build tool
- **Styling:** TailwindCSS with dark mode support
- **Routing:** React Router for SPA navigation
- **State Management:** React Context API for theme and settings
- **Internationalization:** react-i18next (English/Italian)

### Backend (FastAPI + Python)
- **Framework:** FastAPI with async support
- **Documentation:** Auto-generated OpenAPI/Swagger docs
- **CORS:** Configured for frontend integration
- **Configuration:** JSON-based config system

### Infrastructure
- **Containerization:** Docker with multi-stage builds
- **Orchestration:** Docker Compose for service management
- **Reverse Proxy:** Nginx for production deployment
- **SSL:** Certbot integration for HTTPS

## 📁 Project Structure

```
ai-trade-video-social/
├── frontend/                 # React TypeScript application
│   ├── src/
│   │   ├── components/      # Reusable UI components
│   │   ├── contexts/        # React Context providers
│   │   ├── pages/          # Page components
│   │   └── i18n.ts         # Internationalization config
│   ├── Dockerfile          # Production build
│   └── Dockerfile.dev      # Development build
├── backend/                 # FastAPI Python application
│   ├── main.py             # FastAPI application entry point
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Backend container
├── scripts/                # Automation scripts
│   ├── dev/               # Development scripts (setup, start, stop)
│   └── prod/              # Production deployment scripts
├── doc/                    # Documentation
│   ├── DEPLOYMENT.md      # Complete deployment guide
│   ├── PRODUCTION-READY.md # Current production status
│   └── README-DEPLOYMENT.md # Quick reference
├── img/                   # Static assets (logo)
├── config.json           # Application configuration
└── docker-compose.yml    # Production orchestration
```

## 🎨 Features

### User Interface
- **Responsive Design:** Mobile-first approach with Tailwind CSS
- **Dark/Light Mode:** System preference detection with manual toggle
- **Multi-language:** English and Italian support
- **Modern UI:** Clean, professional design with proper color palette

### Functionality
- **Home Page:** Text input with response display
- **Settings Page:** Custom response text configuration
- **Navigation:** Smooth routing between pages
- **State Persistence:** Local storage for theme and settings

### Color Palette
- Primary: `#0AD9E4` (Cyan)
- Secondary: `#FFD300` (Yellow)
- Background: `#FFFFFF` (White)
- Text: `#000000` (Black)
- Dark mode supported

## 🔧 Configuration

The application uses a centralized configuration system in `config.json`:

```json
{
  "app": {
    "name": "AI TradeMaestro",
    "domain": "aitrademaestro.com",
    "version": "1.0.0"
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
  }
}
```

## 🚀 Deployment

### Development
```bash
# Windows
scripts\dev\start.bat

# Linux/Mac
scripts/dev/start.sh
```

### Production Deployment

**📖 Complete Production Guide:** See [doc/PRODUCTION-READY.md](doc/PRODUCTION-READY.md)

**Quick Start:**
```bash
# 1. Setup (installs everything)
./scripts/dev/setup.sh

# 2. Configure environment
cp .env.production.example .env.production
nano .env.production

# 3. Deploy
./scripts/prod/deploy.sh

# 4. Enable HTTPS
./scripts/prod/enable-ssl.sh
```

**📚 Documentation:**
- [Production Ready Status](doc/PRODUCTION-READY.md) - Current status & next steps
- [Quick Start Guide](doc/README-DEPLOYMENT.md) - Fast deployment reference
- [Complete Deployment Guide](doc/DEPLOYMENT.md) - Detailed step-by-step guide

## 🛠️ Development

### Adding New Features
1. Frontend components go in `frontend/src/components/`
2. New pages go in `frontend/src/pages/`
3. Backend endpoints go in `backend/main.py`

### Code Style
- TypeScript strict mode enabled
- ESLint + Prettier for code formatting
- Python follows PEP 8 standards

### Testing
```bash
# Frontend tests
cd frontend && npm test

# Backend tests
cd backend && pytest
```

## 📚 API Documentation

When running, visit http://localhost:8000/docs for interactive API documentation.

### Main Endpoints
- `GET /` - API status
- `GET /health` - Health check
- `POST /api/chat` - Chat interaction
- `GET /api/config` - App configuration

## 🔒 Security Features

- CORS properly configured
- Input validation with Pydantic
- Environment-based configuration
- No sensitive data in repository

## 🐛 Troubleshooting

### Common Issues

1. **Docker not running:** Ensure Docker Desktop is started
2. **Port conflicts:** Check if ports 3000/8000 are available
3. **Build failures:** Clear Docker cache with `docker system prune`

### Logs
```bash
# View all logs
docker-compose -f docker-compose.dev.yml logs -f

# View specific service
docker-compose -f docker-compose.dev.yml logs frontend
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the code style
4. Test your changes
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🏷️ Version

Current version: 1.0.0

Built with ❤️ for modern AI trading applications.