# 🚀 Quick Start - AI TradeMaestro

## One-Command Deployment

Run this **single script** on your VPS to deploy everything from zero to production with HTTPS:

```bash
./scripts/prod/complete-setup.sh
```

**That's it!** ✨

---

## What This Script Does

### ✅ Automatic Setup (All-in-One)

1. **Environment Check**
   - Verifies Docker, Docker Compose, Nginx installed
   - Checks project files and configuration

2. **Certbot Installation**
   - Installs certbot if missing
   - Prepares Let's Encrypt SSL

3. **Native Nginx Configuration**
   - Configures reverse proxy
   - Sets up HTTPS on ports 80/443
   - Proxies to Docker on port 8080

4. **SSL Certificate**
   - Requests Let's Encrypt certificate
   - Configures automatic renewal
   - Enables HTTPS

5. **Docker Deployment**
   - Builds all containers
   - Starts services (nginx, frontend, backend, database, redis)
   - Runs database migrations

6. **Verification**
   - Tests local Docker (port 8080)
   - Tests public HTTPS (port 443)
   - Provides detailed status report

---

## Prerequisites

### Before Running the Script

1. **VPS with Ubuntu/Debian**
   ```bash
   # Check OS
   lsb_release -a
   ```

2. **Install Docker & Docker Compose**
   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh

   # Install Docker Compose
   sudo apt-get update
   sudo apt-get install -y docker-compose-plugin
   ```

3. **Clone Repository**
   ```bash
   cd /root/web_apps
   git clone <your-repo> ai-trade-maestro-video-social
   cd ai-trade-maestro-video-social
   ```

4. **Configure Environment**
   ```bash
   cp .env.production.example .env.production
   nano .env.production
   ```

   Set these variables:
   - `POSTGRES_PASSWORD=your_secure_password`
   - `REDIS_PASSWORD=your_secure_password`
   - `SECRET_KEY=your_very_long_secret_key`
   - `SSL_EMAIL=your@email.com`

5. **DNS Configuration**
   - Point `aitrademaestro.ddns.net` to your VPS IP
   - Verify: `dig aitrademaestro.ddns.net`

---

## Running the Setup

### Step 1: Make Script Executable

```bash
chmod +x scripts/prod/complete-setup.sh
```

### Step 2: Run Setup

```bash
./scripts/prod/complete-setup.sh
```

### Step 3: Wait for Completion

The script will:
- ⏳ Install dependencies (~2 min)
- ⏳ Configure nginx (~1 min)
- ⏳ Request SSL certificate (~30 sec)
- ⏳ Build Docker images (~5 min)
- ⏳ Start services (~30 sec)

**Total time: ~10 minutes**

---

## Expected Output

### ✅ Success

```
====================================================================
   🎉 DEPLOYMENT SUCCESSFUL!
====================================================================

Your application is live at:
   https://aitrademaestro.ddns.net

✅ All services running
✅ SSL certificate installed
✅ Public HTTPS access working
```

### ⚠️ Warnings

```
====================================================================
   ⚠️  DEPLOYMENT COMPLETED WITH WARNINGS
====================================================================

Your application is accessible at:
   http://localhost:8080 (Docker)
   https://aitrademaestro.ddns.net (if DNS/firewall configured)

⚠️  Some components need attention (see warnings above)
```

**Common warnings and fixes:**
- **SSL Failed**: Check DNS points to VPS IP
- **Public HTTPS Not Working**: Open ports 80/443 in firewall
- **Containers Not Running**: Check Docker logs

---

## Verification

### Test Locally

```bash
# Test Docker directly
curl http://localhost:8080

# Expected: HTTP 200 OK
```

### Test Publicly

```bash
# Test HTTPS
curl https://aitrademaestro.ddns.net

# Expected: HTTP 200 OK with your app
```

### Check Services

```bash
# Native nginx
sudo systemctl status nginx

# Docker containers
docker ps

# Logs
sudo tail -f /var/log/nginx/aitrademaestro_error.log
docker logs aitrademaestro-nginx
```

---

## Troubleshooting

### Issue: SSL Certificate Failed

**Cause:** DNS not pointing to VPS or ports blocked

**Fix:**
```bash
# Check DNS
dig aitrademaestro.ddns.net

# Check public IP
curl ifconfig.me

# Open firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Retry SSL
sudo certbot --nginx -d aitrademaestro.ddns.net
```

### Issue: Docker Not Starting

**Cause:** Port conflict or missing .env

**Fix:**
```bash
# Check .env.production exists
ls -la .env.production

# Check ports
sudo ss -tulpn | grep ':8080'

# Restart Docker
docker-compose -f docker-compose.prod.yml restart
```

### Issue: 502 Bad Gateway

**Cause:** Docker not running or wrong proxy port

**Fix:**
```bash
# Check Docker
docker ps | grep aitrademaestro

# Restart everything
sudo systemctl reload nginx
docker-compose -f docker-compose.prod.yml restart
```

---

## Architecture

```
Internet (HTTPS:443)
         ↓
Native Nginx (VPS)
         ↓ [Reverse Proxy]
Docker Nginx (8080)
         ↓
Frontend/Backend Containers
```

**Port Mapping:**
- **80/443** → Native Nginx (SSL, public)
- **8080** → Docker Nginx (internal)
- **8000** → Backend (internal)
- **3000** → Frontend (internal)

---

## Maintenance

### View Logs

```bash
# Native nginx
sudo tail -f /var/log/nginx/aitrademaestro_error.log

# Docker
docker-compose -f docker-compose.prod.yml logs -f
```

### Restart Services

```bash
# Native nginx
sudo systemctl reload nginx

# Docker
docker-compose -f docker-compose.prod.yml restart
```

### Update Application

```bash
# Pull latest code
git pull origin main

# Redeploy
./scripts/prod/deploy.sh
```

### Renew SSL Certificate

```bash
# Test renewal
sudo certbot renew --dry-run

# Force renewal
sudo certbot renew --force-renewal
```

---

## Quick Commands

```bash
# Full status check
sudo systemctl status nginx
docker ps
sudo certbot certificates

# Restart everything
sudo systemctl reload nginx
docker-compose -f docker-compose.prod.yml restart

# View all logs
sudo tail -f /var/log/nginx/aitrademaestro_*.log &
docker-compose -f docker-compose.prod.yml logs -f

# Redeploy from scratch
./scripts/prod/complete-setup.sh
```

---

## Support

If the script fails:

1. **Check the error output** - The script provides detailed logs
2. **Verify prerequisites** - Docker, DNS, .env.production
3. **Check firewall** - Ports 80/443 must be open
4. **Review logs** - Native nginx and Docker logs

**Still stuck?** Check `SETUP-VPS.md` for detailed troubleshooting.

---

**🎉 Your app should now be live at https://aitrademaestro.ddns.net!**
