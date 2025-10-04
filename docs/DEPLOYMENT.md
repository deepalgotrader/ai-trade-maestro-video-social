# 🚀 AI TradeMaestro - Deployment Guide

## 📋 Overview

This guide covers deploying AI TradeMaestro with **automatic HTTPS/SSL setup** using Let's Encrypt certificates.

---

## ✅ Prerequisites

Before deploying, ensure you have:

1. **Server Requirements**
   - Linux server (Ubuntu 20.04+ recommended)
   - Docker & Docker Compose installed
   - Ports 80 and 443 open in firewall
   - At least 2GB RAM, 20GB disk space

2. **Domain Setup**
   - Domain name pointing to your server IP (e.g., `aitrademaestro.ddns.net`)
   - DNS A record configured and propagated
   - Verify with: `dig aitrademaestro.ddns.net`

3. **Environment Configuration**
   - Copy `.env.production.example` to `.env.production`
   - Configure all required variables (database passwords, secrets, etc.)

---

## 🚀 Quick Deployment (Recommended)

### Single Command Deployment with Auto-SSL

```bash
./scripts/prod/deploy.sh
```

**What this does:**
1. ✅ Validates `.env.production` file exists
2. ✅ Stops existing services
3. ✅ Builds Docker images
4. ✅ Starts all services (nginx, frontend, backend, database)
5. ✅ Runs database migrations
6. ✅ Tests HTTP accessibility
7. ✅ **Checks if server is publicly accessible**
8. ✅ **Automatically obtains SSL certificate (if publicly accessible)**
9. ✅ **Configures HTTPS with automatic HTTP→HTTPS redirect**
10. ✅ Tests and verifies HTTPS is working

**Possible Outcomes:**

### ✅ Success - HTTPS Enabled
```
🎉 Deployment Completed with HTTPS!

🔒 Your application is now live and secure at:
   https://aitrademaestro.ddns.net

✓ All HTTP traffic automatically redirects to HTTPS
✓ SSL certificate auto-renews every 90 days
✓ WhatsApp and other services can now open your links
```

### ⚠️ HTTP Only (Server Publicly Accessible but SSL Failed)
```
⚠️  Deployment Completed (HTTP Only)

Your application is accessible at:
   http://aitrademaestro.ddns.net

SSL setup failed. Common issues:
  • Port 80/443 not accessible from internet
  • Firewall blocking Let's Encrypt validation
  • DNS not fully propagated

To retry SSL manually:
  ./scripts/prod/enable-ssl.sh
```

### 📍 Local Only (Server Not Publicly Accessible)
```
✓ Deployment Completed (Local Only)

Your application is running at:
   http://localhost

⚠️  To enable public access and SSL:
  1. Ensure port 80/443 are open in firewall
  2. Configure port forwarding (if behind NAT)
  3. Verify DNS points to your public IP
  4. Run: ./scripts/prod/enable-ssl.sh
```

---

## 🔧 Manual SSL Setup (If Needed)

If automatic SSL fails or you need to retry:

### Enable SSL Manually
```bash
./scripts/prod/enable-ssl.sh
```

### Force Enable SSL
If SSL certificate exists but needs reactivation:
```bash
./scripts/prod/force-enable-ssl.sh
```

---

## 📊 Service Management

### View Logs
```bash
./scripts/prod/logs.sh
```

### Restart Services
```bash
./scripts/prod/restart.sh
```

### Stop Services
```bash
./scripts/prod/stop.sh
```

### Check Service Status
```bash
docker ps --filter "name=aitrademaestro"
```

---

## 🔒 SSL Certificate Details

### How It Works

1. **Initial Deployment**
   - Uses `nginx/conf.d/app-initial.conf` (HTTP-only for certificate validation)
   - Certbot obtains certificate from Let's Encrypt via HTTP-01 challenge
   - Nginx switches to `nginx/conf.d/app.conf` (HTTPS with redirect)

2. **Certificate Location**
   - Certificates stored in: `./nginx/certbot/conf/`
   - Certificate files:
     - `fullchain.pem` - Full certificate chain
     - `privkey.pem` - Private key
     - `chain.pem` - Intermediate certificates

3. **Auto-Renewal**
   - Certbot container runs renewal check every 12 hours
   - Certificates valid for 90 days
   - Auto-renews when < 30 days remain

### Manual Certificate Management

**List Certificates:**
```bash
docker-compose -f docker-compose.prod.yml run --rm certbot certificates
```

**Force Renewal:**
```bash
docker-compose -f docker-compose.prod.yml run --rm certbot renew --force-renewal
docker-compose -f docker-compose.prod.yml restart nginx
```

**Check Certificate Expiry:**
```bash
echo | openssl s_client -servername aitrademaestro.ddns.net -connect aitrademaestro.ddns.net:443 2>/dev/null | openssl x509 -noout -dates
```

---

## 🌐 Verifying Deployment

### 1. Check HTTPS is Working
```bash
curl -I https://aitrademaestro.ddns.net
```

Expected: `HTTP/2 200`

### 2. Verify HTTP→HTTPS Redirect
```bash
curl -I http://aitrademaestro.ddns.net
```

Expected: `HTTP/1.1 301 Moved Permanently` with `Location: https://...`

### 3. Test API Endpoint
```bash
curl https://aitrademaestro.ddns.net/api/health
```

### 4. Test SSL Certificate
```bash
openssl s_client -connect aitrademaestro.ddns.net:443 -servername aitrademaestro.ddns.net < /dev/null
```

### 5. Browser Test
Open in browser: https://aitrademaestro.ddns.net
- Should show 🔒 padlock icon
- Certificate should be valid and trusted
- No security warnings

---

## 🐛 Troubleshooting

### Issue: SSL Certificate Not Obtained

**Symptoms:**
- `enable-ssl.sh` fails
- Certificate validation errors

**Solutions:**

1. **Check DNS:**
   ```bash
   dig aitrademaestro.ddns.net
   nslookup aitrademaestro.ddns.net
   ```
   Ensure it points to your server IP

2. **Check Firewall:**
   ```bash
   sudo ufw status
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

3. **Check HTTP is Accessible:**
   ```bash
   curl http://aitrademaestro.ddns.net/.well-known/acme-challenge/test
   ```

4. **Check Nginx Logs:**
   ```bash
   docker logs aitrademaestro-nginx --tail 50
   ```

5. **Verify Certbot:**
   ```bash
   docker-compose -f docker-compose.prod.yml run --rm certbot --version
   ```

### Issue: HTTPS Not Working After Deployment

**Solutions:**

1. **Check Nginx Configuration:**
   ```bash
   docker exec aitrademaestro-nginx nginx -t
   ```

2. **Verify Certificate Files Exist:**
   ```bash
   ls -la nginx/certbot/conf/live/aitrademaestro.ddns.net/
   ```

3. **Restart Nginx:**
   ```bash
   docker-compose -f docker-compose.prod.yml restart nginx
   ```

4. **Force Enable SSL:**
   ```bash
   ./scripts/prod/force-enable-ssl.sh
   ```

### Issue: Mixed Content Warnings

**Cause:** Frontend making HTTP requests instead of HTTPS

**Solution:**
Ensure environment variables use HTTPS:
```bash
# In .env.production
NEXT_PUBLIC_API_URL=https://aitrademaestro.ddns.net/api
```

Rebuild frontend:
```bash
docker-compose -f docker-compose.prod.yml up -d --build frontend
```

### Issue: Certificate Renewal Failed

**Solutions:**

1. **Manual Renewal:**
   ```bash
   docker-compose -f docker-compose.prod.yml run --rm certbot renew
   docker-compose -f docker-compose.prod.yml restart nginx
   ```

2. **Check Certbot Container:**
   ```bash
   docker logs aitrademaestro-certbot
   ```

---

## 🔐 Security Best Practices

### Implemented Security Features

✅ **TLS 1.2/1.3** - Modern encryption protocols
✅ **HSTS** - HTTP Strict Transport Security
✅ **Strong Ciphers** - ECDHE ciphers with forward secrecy
✅ **OCSP Stapling** - Faster certificate validation
✅ **Security Headers** - X-Frame-Options, X-Content-Type-Options, etc.
✅ **Auto HTTP→HTTPS Redirect** - All traffic encrypted

### Additional Recommendations

1. **Keep Docker Images Updated:**
   ```bash
   docker-compose -f docker-compose.prod.yml pull
   docker-compose -f docker-compose.prod.yml up -d
   ```

2. **Monitor Certificate Expiry:**
   Set up monitoring/alerts for certificates expiring < 30 days

3. **Backup Certificates:**
   ```bash
   tar -czf ssl-backup-$(date +%Y%m%d).tar.gz nginx/certbot/conf/
   ```

4. **Regular Security Audits:**
   - Test SSL: https://www.ssllabs.com/ssltest/
   - Scan headers: https://securityheaders.com/

---

## 📱 WhatsApp & Social Media Compatibility

With HTTPS enabled, your links will now work on:

✅ WhatsApp
✅ Facebook Messenger
✅ Instagram
✅ Twitter/X
✅ LinkedIn
✅ Telegram
✅ All modern browsers

These platforms require HTTPS for security and will block or warn about HTTP links.

---

## 🔄 Update & Redeploy

To update the application:

```bash
# 1. Pull latest code
git pull origin main

# 2. Redeploy (preserves SSL certificates)
./scripts/prod/deploy.sh
```

SSL certificates are preserved across deployments in `./nginx/certbot/conf/` volume.

---

## 📞 Support

If you encounter issues:

1. Check logs: `./scripts/prod/logs.sh`
2. Review this troubleshooting guide
3. Check Docker status: `docker ps -a`
4. Verify DNS: `dig aitrademaestro.ddns.net`
5. Test connectivity: `curl -v https://aitrademaestro.ddns.net`

---

## ✅ Deployment Checklist

- [ ] Server has Docker & Docker Compose
- [ ] Ports 80 and 443 are open
- [ ] Domain DNS points to server IP
- [ ] `.env.production` configured
- [ ] Run `./scripts/prod/deploy.sh`
- [ ] Verify HTTPS works: `curl -I https://aitrademaestro.ddns.net`
- [ ] Test in browser with 🔒 padlock
- [ ] Share link in WhatsApp to verify compatibility

---

**🎉 Congratulations!** Your AI TradeMaestro application is now deployed with automatic HTTPS!
