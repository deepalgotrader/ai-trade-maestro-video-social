# AI TradeMaestro - Guida al Deployment in Produzione

## Panoramica del Deployment

Questa guida fornisce istruzioni dettagliate per il deployment di AI TradeMaestro in ambiente di produzione utilizzando Docker, Nginx e configurazioni sicure.

## Prerequisiti Produzione

### Infrastructure Requirements

#### Server Minimo
- **CPU**: 2 core (4 core raccomandati)
- **RAM**: 4GB (8GB raccomandati)
- **Storage**: 50GB SSD (100GB raccomandati)
- **Network**: 100 Mbps bandwidth
- **OS**: Ubuntu 20.04 LTS o CentOS 8+

#### Software Stack
- **Docker**: 20.10.0+
- **Docker Compose**: 2.0.0+
- **Nginx**: (tramite container)
- **SSL Certificate**: Let's Encrypt o certificato commerciale

### Domain e DNS
- **Dominio principale**: `aitrademaestro.com`
- **API subdomain**: `api.aitrademaestro.com`
- **CDN subdomain**: `cdn.aitrademaestro.com` (opzionale)

## Preparazione Server

### 1. Setup Server Iniziale

```bash
# Update sistema
sudo apt update && sudo apt upgrade -y

# Install essentials
sudo apt install -y curl wget git htop ufw

# Setup firewall
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable
```

### 2. Installazione Docker

```bash
# Remove old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### 3. Security Hardening

```bash
# Disable root SSH
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Setup automatic updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Install fail2ban
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## Configurazione Ambiente Produzione

### 1. Struttura Directory

```bash
# Create application directory
sudo mkdir -p /opt/aitrademaestro
sudo chown $USER:$USER /opt/aitrademaestro
cd /opt/aitrademaestro

# Clone repository
git clone <repository-url> .

# Create production directories
mkdir -p {nginx/ssl,nginx/conf.d,logs,backups,data/postgres,data/redis}
```

### 2. Environment Variables

#### Production .env

```bash
# Create production environment file
cat > .env.production << 'EOF'
# Environment
ENVIRONMENT=production
DEBUG=false

# Security
SECRET_KEY=super-secret-production-key-min-32-chars
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Database
POSTGRES_DB=aitrademaestro_prod
POSTGRES_USER=aitrademaestro
POSTGRES_PASSWORD=secure-db-password-change-this
DATABASE_URL=postgresql://aitrademaestro:secure-db-password-change-this@db:5432/aitrademaestro_prod

# Redis
REDIS_URL=redis://redis:6379/0
REDIS_PASSWORD=secure-redis-password

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4

# Frontend
VITE_API_BASE_URL=https://api.aitrademaestro.com
VITE_ENVIRONMENT=production
VITE_DEBUG=false

# Email (configure based on your provider)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@aitrademaestro.com
SMTP_PASSWORD=app-specific-password

# Monitoring
SENTRY_DSN=your-sentry-dsn-here
LOG_LEVEL=info

# Backup
BACKUP_RETENTION_DAYS=30
EOF

# Secure the file
chmod 600 .env.production
```

### 3. Docker Production Configuration

#### Production Docker Compose

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: aitrademaestro_nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - ./logs/nginx:/var/log/nginx
    depends_on:
      - frontend
      - backend
    networks:
      - aitrademaestro_network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    container_name: aitrademaestro_frontend
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    volumes:
      - frontend_dist:/app/dist
    networks:
      - aitrademaestro_network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    container_name: aitrademaestro_backend
    restart: unless-stopped
    env_file:
      - .env.production
    volumes:
      - ./logs/backend:/app/logs
      - ./data/uploads:/app/uploads
    depends_on:
      - db
      - redis
    networks:
      - aitrademaestro_network

  db:
    image: postgres:15-alpine
    container_name: aitrademaestro_db
    restart: unless-stopped
    env_file:
      - .env.production
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
      - ./backups:/backups
    networks:
      - aitrademaestro_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    container_name: aitrademaestro_redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - ./data/redis:/data
    networks:
      - aitrademaestro_network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  frontend_dist:

networks:
  aitrademaestro_network:
    driver: bridge
```

## Configurazione SSL/HTTPS

### 1. Let's Encrypt con Certbot

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Generate SSL certificate
sudo certbot certonly --standalone \
  -d aitrademaestro.com \
  -d api.aitrademaestro.com \
  --email admin@aitrademaestro.com \
  --agree-tos \
  --no-eff-email

# Copy certificates to nginx directory
sudo cp /etc/letsencrypt/live/aitrademaestro.com/fullchain.pem ./nginx/ssl/
sudo cp /etc/letsencrypt/live/aitrademaestro.com/privkey.pem ./nginx/ssl/
sudo chown $USER:$USER ./nginx/ssl/*

# Setup auto-renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

### 2. Nginx Production Configuration

```nginx
# nginx/nginx.conf
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    # Optimization
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 10M;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self' https://api.aitrademaestro.com;";

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=web:10m rate=30r/s;

    # Upstream definitions
    upstream frontend {
        server frontend:3000;
    }

    upstream backend {
        server backend:8000;
    }

    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name aitrademaestro.com api.aitrademaestro.com;
        return 301 https://$server_name$request_uri;
    }

    # Main website
    server {
        listen 443 ssl http2;
        server_name aitrademaestro.com;

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        location / {
            limit_req zone=web burst=20 nodelay;
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # API subdomain
    server {
        listen 443 ssl http2;
        server_name api.aitrademaestro.com;

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        location / {
            limit_req zone=api burst=10 nodelay;
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            access_log off;
            proxy_pass http://backend;
        }
    }
}
```

## Build e Deployment

### 1. Production Dockerfiles

#### Frontend Dockerfile.prod

```dockerfile
# frontend/Dockerfile.prod
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### Backend Dockerfile.prod

```dockerfile
# backend/Dockerfile.prod
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

### 2. Deployment Script

```bash
#!/bin/bash
# deploy.sh

set -e

echo "🚀 Starting AI TradeMaestro deployment..."

# Variables
COMPOSE_FILE="docker-compose.prod.yml"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

# Create backup
echo "📦 Creating backup..."
mkdir -p $BACKUP_DIR
docker-compose -f $COMPOSE_FILE exec db pg_dump -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_DIR/database.sql
docker-compose -f $COMPOSE_FILE exec redis redis-cli --rdb - > $BACKUP_DIR/redis.rdb

# Pull latest code
echo "📥 Pulling latest code..."
git pull origin main

# Build new images
echo "🔨 Building new images..."
docker-compose -f $COMPOSE_FILE build --no-cache

# Stop old containers
echo "⏹️ Stopping old containers..."
docker-compose -f $COMPOSE_FILE down

# Start new containers
echo "▶️ Starting new containers..."
docker-compose -f $COMPOSE_FILE up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 30

# Health check
echo "🏥 Running health checks..."
curl -f http://localhost/health || exit 1
curl -f http://localhost:8000/health || exit 1

# Cleanup old images
echo "🧹 Cleaning up old images..."
docker image prune -f

echo "✅ Deployment completed successfully!"
```

### 3. Database Migrations

```bash
# Run migrations in production
docker-compose -f docker-compose.prod.yml exec backend alembic upgrade head

# Create new migration
docker-compose -f docker-compose.prod.yml exec backend alembic revision --autogenerate -m "Migration description"
```

## Monitoring e Maintenance

### 1. Health Monitoring

```bash
# health-check.sh
#!/bin/bash

# Services to check
SERVICES=("aitrademaestro_nginx" "aitrademaestro_frontend" "aitrademaestro_backend" "aitrademaestro_db" "aitrademaestro_redis")

for service in "${SERVICES[@]}"; do
    if docker ps | grep -q $service; then
        echo "✅ $service is running"
    else
        echo "❌ $service is down"
        # Send alert (email, Slack, etc.)
        curl -X POST -H 'Content-type: application/json' \
            --data '{"text":"🚨 Service '$service' is down on AI TradeMaestro production!"}' \
            $SLACK_WEBHOOK_URL
    fi
done

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "⚠️ Disk usage is at $DISK_USAGE%"
fi

# Check memory usage
MEMORY_USAGE=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
    echo "⚠️ Memory usage is at $MEMORY_USAGE%"
fi
```

### 2. Backup Strategy

```bash
# backup.sh
#!/bin/bash

BACKUP_ROOT="/opt/aitrademaestro/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$DATE"
RETENTION_DAYS=30

# Create backup directory
mkdir -p $BACKUP_DIR

# Database backup
echo "Backing up database..."
docker-compose exec db pg_dump -U $POSTGRES_USER $POSTGRES_DB | gzip > $BACKUP_DIR/database.sql.gz

# Redis backup
echo "Backing up Redis..."
docker-compose exec redis redis-cli --rdb - | gzip > $BACKUP_DIR/redis.rdb.gz

# Application data backup
echo "Backing up application data..."
tar -czf $BACKUP_DIR/uploads.tar.gz ./data/uploads
tar -czf $BACKUP_DIR/logs.tar.gz ./logs

# Cleanup old backups
echo "Cleaning up old backups..."
find $BACKUP_ROOT -type d -mtime +$RETENTION_DAYS -exec rm -rf {} +

echo "Backup completed: $BACKUP_DIR"
```

### 3. Log Management

```bash
# log-rotate.sh
#!/bin/bash

# Rotate application logs
docker-compose exec backend find /app/logs -name "*.log" -size +100M -exec gzip {} \;

# Cleanup old logs
docker-compose exec backend find /app/logs -name "*.gz" -mtime +7 -delete

# Nginx log rotation (handled by logrotate)
cat > /etc/logrotate.d/aitrademaestro << 'EOF'
/opt/aitrademaestro/logs/nginx/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    postrotate
        docker kill -s USR1 aitrademaestro_nginx
    endscript
}
EOF
```

## Performance Optimization

### 1. Database Optimization

```sql
-- Create indexes for performance
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_sessions_user_id ON sessions(user_id);
CREATE INDEX CONCURRENTLY idx_trades_created_at ON trades(created_at);

-- Analyze tables
ANALYZE;
```

### 2. Caching Strategy

```python
# Redis caching configuration
CACHE_CONFIG = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://redis:6379/0',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        },
        'KEY_PREFIX': 'aitrademaestro',
        'TIMEOUT': 300,
    }
}
```

### 3. CDN Integration

```nginx
# CDN configuration
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    add_header Vary Accept-Encoding;

    # Optional: redirect to CDN
    # return 302 https://cdn.aitrademaestro.com$uri;
}
```

## Security Best Practices

### 1. Container Security

```bash
# Run containers as non-root user
# Already configured in Dockerfiles

# Scan images for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image aitrademaestro_backend:latest

# Update base images regularly
docker pull node:18-alpine
docker pull python:3.11-slim
```

### 2. Network Security

```bash
# Setup fail2ban for nginx
cat > /etc/fail2ban/jail.d/nginx.conf << 'EOF'
[nginx-http-auth]
enabled = true
port = http,https
logpath = /opt/aitrademaestro/logs/nginx/error.log

[nginx-limit-req]
enabled = true
port = http,https
logpath = /opt/aitrademaestro/logs/nginx/error.log
maxretry = 10
findtime = 600
bantime = 7200
EOF

sudo systemctl restart fail2ban
```

### 3. Secrets Management

```bash
# Use Docker secrets for sensitive data
echo "super-secret-db-password" | docker secret create db_password -
echo "super-secret-api-key" | docker secret create api_key -

# Update docker-compose to use secrets
# secrets:
#   db_password:
#     external: true
#   api_key:
#     external: true
```

## Troubleshooting Production

### 1. Container Issues

```bash
# View container logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db

# Enter container for debugging
docker-compose exec backend bash
docker-compose exec db psql -U $POSTGRES_USER $POSTGRES_DB

# Check container resources
docker stats
```

### 2. Performance Issues

```bash
# Monitor system resources
htop
iotop
nethogs

# Check database performance
docker-compose exec db psql -U $POSTGRES_USER $POSTGRES_DB -c "
SELECT query, calls, total_time, rows, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;"
```

### 3. SSL/Certificate Issues

```bash
# Check SSL certificate
openssl s_client -connect aitrademaestro.com:443 -servername aitrademaestro.com

# Renew Let's Encrypt certificate
sudo certbot renew
sudo systemctl reload nginx
```

## Disaster Recovery

### 1. Full System Restore

```bash
# Stop all services
docker-compose -f docker-compose.prod.yml down

# Restore database
gunzip -c $BACKUP_DIR/database.sql.gz | docker-compose exec -T db psql -U $POSTGRES_USER $POSTGRES_DB

# Restore Redis
gunzip -c $BACKUP_DIR/redis.rdb.gz > ./data/redis/dump.rdb

# Restore application data
tar -xzf $BACKUP_DIR/uploads.tar.gz -C ./

# Start services
docker-compose -f docker-compose.prod.yml up -d
```

### 2. Rollback Strategy

```bash
# Tag current deployment
git tag v1.0.$(date +%Y%m%d_%H%M%S)

# Rollback to previous version
git checkout v1.0.previous
./deploy.sh
```

Questa guida fornisce una base solida per il deployment in produzione di AI TradeMaestro con considerazioni per sicurezza, performance e manutenibilità.