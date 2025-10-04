# 🖥️ VPS Setup Guide - AI TradeMaestro

## Architecture Overview

Your VPS runs **two nginx instances**:

1. **Native Nginx** (ports 80/443)
   - Handles SSL certificates via Let's Encrypt
   - Manages multiple domains (trading-lab.ddns.net, aitrademaestro.ddns.net, etc.)
   - Acts as reverse proxy to applications

2. **Docker Nginx** (ports 8080/8443)
   - Runs inside Docker container
   - Serves AI TradeMaestro app
   - Receives traffic from native nginx

```
Internet (80/443)
    ↓
Native Nginx (VPS)
    ↓
Docker Nginx (8080/8443)
    ↓
Frontend/Backend Containers
```

---

## 📋 Prerequisites

Ensure you have:
- VPS with Ubuntu/Debian
- Docker & Docker Compose installed
- Native nginx already running (with other apps)
- Domain DNS pointing to VPS IP

---

## 🚀 Setup Instructions

### Step 1: Clone Repository on VPS

```bash
cd /root/web_apps
git clone <your-repo-url> ai-trade-maestro-video-social
cd ai-trade-maestro-video-social
```

### Step 2: Configure Environment

```bash
# Create .env.production
cp .env.production.example .env.production
nano .env.production
```

Configure:
- `POSTGRES_PASSWORD`
- `REDIS_PASSWORD`
- `SECRET_KEY`
- `SSL_EMAIL`

### Step 3: Setup Native Nginx (One-time)

This configures the native nginx to proxy to Docker:

```bash
./scripts/prod/setup-native-nginx.sh
```

**What this does:**
1. ✅ Creates `/var/www/certbot-aitrademaestro` directory
2. ✅ Copies nginx config to `/etc/nginx/sites-available/`
3. ✅ Enables the site
4. ✅ Requests SSL certificate from Let's Encrypt
5. ✅ Configures HTTPS with reverse proxy to port 8080

**Expected Output:**
```
✅ Native Nginx Setup Complete!

🔒 Your application is now accessible at:
   https://aitrademaestro.ddns.net

Configuration:
  • Native Nginx: Handles SSL on ports 80/443
  • Reverse Proxy: → localhost:8080 (Docker)
  • SSL Certificate: Auto-managed by certbot
```

### Step 4: Deploy Docker Application

```bash
./scripts/prod/deploy.sh
```

This starts Docker containers on ports 8080/8443.

**Expected Output:**
```
✓ Deployment Completed (Local Only)

Your application is running at:
   http://localhost:8080
```

### Step 5: Verify Everything Works

```bash
# Test locally
curl http://localhost:8080

# Test publicly (through native nginx proxy)
curl https://aitrademaestro.ddns.net
```

---

## 🔧 Port Configuration

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| Native Nginx | 80 | HTTP | Public HTTP, redirects to HTTPS |
| Native Nginx | 443 | HTTPS | Public HTTPS, proxies to Docker |
| Docker Nginx | 8080 | HTTP | Internal, receives from native nginx |
| Docker Nginx | 8443 | HTTPS | Internal (not used) |
| Backend | 8000 | HTTP | Internal only |
| Frontend | 3000 | HTTP | Internal only |

---

## 🔒 SSL Certificate Management

### Certificates are managed by **Native Nginx (Certbot)**

```bash
# List certificates
sudo certbot certificates

# Renew manually
sudo certbot renew

# Auto-renewal (already configured)
# Certbot renews automatically via cron/systemd timer
```

### Certificate Location

```bash
/etc/letsencrypt/live/aitrademaestro.ddns.net/
├── fullchain.pem
├── privkey.pem
├── cert.pem
└── chain.pem
```

---

## 📊 Managing Applications

### Native Nginx Commands

```bash
# Reload configuration
sudo systemctl reload nginx

# Restart nginx
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx

# Test configuration
sudo nginx -t

# View logs
sudo tail -f /var/log/nginx/aitrademaestro_error.log
sudo tail -f /var/log/nginx/aitrademaestro_access.log
```

### Docker Application Commands

```bash
# View logs
./scripts/prod/logs.sh

# Restart
./scripts/prod/restart.sh

# Stop
./scripts/prod/stop.sh

# Redeploy
./scripts/prod/deploy.sh
```

---

## 🐛 Troubleshooting

### Issue: "Port 80/443 already in use"

**Solution:** Use the multi-app setup (already configured)
- Native nginx uses 80/443
- Docker uses 8080/8443
- Native nginx proxies to Docker

### Issue: "502 Bad Gateway"

**Causes:**
1. Docker containers not running
2. Wrong proxy_pass port in native nginx

**Fix:**
```bash
# Check Docker containers
docker ps | grep aitrademaestro

# Check native nginx config
sudo nginx -t

# Restart both
sudo systemctl reload nginx
docker-compose -f docker-compose.prod.yml restart
```

### Issue: "SSL Certificate Error"

**Fix:**
```bash
# Renew certificate
sudo certbot renew --force-renewal

# Reload nginx
sudo systemctl reload nginx
```

### Issue: "Can't connect to Docker app"

**Debug:**
```bash
# Test Docker directly
curl http://localhost:8080

# Check Docker logs
docker logs aitrademaestro-nginx

# Check native nginx proxy
sudo tail -f /var/log/nginx/aitrademaestro_error.log
```

---

## 🔄 Update & Redeploy

```bash
# Pull latest code
cd /root/web_apps/ai-trade-maestro-video-social
git pull origin main

# Redeploy
./scripts/prod/deploy.sh
```

Native nginx configuration persists across Docker redeployments.

---

## 📁 File Locations

### VPS Native Nginx
- Config: `/etc/nginx/sites-available/aitrademaestro`
- Enabled: `/etc/nginx/sites-enabled/aitrademaestro`
- Logs: `/var/log/nginx/aitrademaestro_*.log`
- SSL: `/etc/letsencrypt/live/aitrademaestro.ddns.net/`

### Docker Application
- Project: `/root/web_apps/ai-trade-maestro-video-social`
- Config: `docker-compose.prod.yml`
- Env: `.env.production`
- Logs: `./logs/` (mounted volume)

---

## ✅ Health Checks

```bash
# Native Nginx
sudo systemctl status nginx
sudo nginx -t

# Docker Containers
docker ps --filter "name=aitrademaestro"

# SSL Certificate
sudo certbot certificates | grep aitrademaestro

# Full Stack
curl -I https://aitrademaestro.ddns.net
```

---

## 🎯 Quick Commands Cheat Sheet

```bash
# Deploy fresh
./scripts/prod/deploy.sh

# Restart everything
sudo systemctl reload nginx
docker-compose -f docker-compose.prod.yml restart

# View all logs
sudo tail -f /var/log/nginx/aitrademaestro_*.log
docker-compose -f docker-compose.prod.yml logs -f

# Check status
sudo systemctl status nginx
docker ps

# SSL renewal
sudo certbot renew
```

---

**🎉 Your VPS is now running multiple applications with SSL!**
