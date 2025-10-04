#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

DOMAIN="aitrademaestro.ddns.net"

echo "=========================================="
echo "SSL Status Check"
echo "=========================================="
echo ""

# Check if certificate directory exists on host
echo ">>> Checking certificate files on host..."
if [ -d "nginx/certbot/conf/live/$DOMAIN" ]; then
    echo "✅ Certificate directory EXISTS on host!"
    echo ""
    echo "Certificate files:"
    ls -lh "nginx/certbot/conf/live/$DOMAIN/" 2>/dev/null || echo "Cannot list files"

    echo ""
    echo "Certificate details:"
    if [ -f "nginx/certbot/conf/live/$DOMAIN/cert.pem" ]; then
        openssl x509 -in "nginx/certbot/conf/live/$DOMAIN/cert.pem" -noout -dates -subject 2>/dev/null || echo "Cannot read certificate"
    fi
else
    echo "❌ Certificate directory NOT found on host"
    echo "   Path: nginx/certbot/conf/live/$DOMAIN"
fi

# Check certificates via certbot container
echo ""
echo ">>> Checking certificates via certbot container..."
docker-compose -f docker-compose.prod.yml run --rm certbot certificates || echo "Cannot check certificates"

# Check nginx configuration
echo ""
echo ">>> Checking Nginx SSL configuration..."
if [ -f "nginx/conf.d/app.conf" ]; then
    if grep -q "listen 443 ssl" nginx/conf.d/app.conf; then
        echo "✅ SSL configuration ACTIVE in app.conf"
        echo ""
        echo "SSL certificate paths in config:"
        grep "ssl_certificate" nginx/conf.d/app.conf | head -3
    else
        echo "❌ SSL configuration NOT active in app.conf"
        echo "   Using HTTP-only configuration"
    fi
else
    echo "❌ app.conf not found"
fi

# Check which config nginx is using
echo ""
echo ">>> Checking active Nginx configuration..."
docker exec aitrademaestro-nginx ls -lh /etc/nginx/conf.d/ 2>/dev/null || echo "Cannot check nginx config"

# Test nginx config validity
echo ""
echo ">>> Testing Nginx configuration validity..."
docker exec aitrademaestro-nginx nginx -t 2>&1 || echo "Nginx config test failed"

# Check HTTPS locally
echo ""
echo ">>> Testing HTTPS locally..."
HTTPS_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost 2>/dev/null || echo "000")
if [ "$HTTPS_CODE" = "200" ]; then
    echo "✅ HTTPS works locally (status: $HTTPS_CODE)"
elif [ "$HTTPS_CODE" = "000" ]; then
    echo "❌ HTTPS not responding (nginx might be using HTTP-only config)"
else
    echo "⚠️  HTTPS returned status: $HTTPS_CODE"
fi

# Summary
echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""

# Determine status
CERT_EXISTS=false
SSL_CONFIG=false
HTTPS_WORKS=false

if [ -d "nginx/certbot/conf/live/$DOMAIN" ]; then
    CERT_EXISTS=true
fi

if grep -q "listen 443 ssl" nginx/conf.d/app.conf 2>/dev/null; then
    SSL_CONFIG=true
fi

if [ "$HTTPS_CODE" = "200" ]; then
    HTTPS_WORKS=true
fi

echo "Certificate exists: $([ "$CERT_EXISTS" = true ] && echo "✅ YES" || echo "❌ NO")"
echo "SSL config active: $([ "$SSL_CONFIG" = true ] && echo "✅ YES" || echo "❌ NO")"
echo "HTTPS working: $([ "$HTTPS_WORKS" = true ] && echo "✅ YES" || echo "❌ NO")"
echo ""

# Recommendations
if [ "$CERT_EXISTS" = true ] && [ "$SSL_CONFIG" = true ] && [ "$HTTPS_WORKS" = false ]; then
    echo "📋 Next steps:"
    echo "   Certificate exists and config is ready, but HTTPS not working."
    echo "   Try restarting nginx:"
    echo "   docker-compose -f docker-compose.prod.yml restart nginx"
    echo ""
elif [ "$CERT_EXISTS" = true ] && [ "$SSL_CONFIG" = false ]; then
    echo "📋 Next steps:"
    echo "   Certificate exists but nginx using HTTP-only config."
    echo "   Switch to SSL config:"
    echo "   cp nginx/conf.d/app.conf nginx/conf.d/app-ssl.conf.bak"
    echo "   # Ensure app.conf has SSL configuration"
    echo "   docker-compose -f docker-compose.prod.yml restart nginx"
    echo ""
elif [ "$CERT_EXISTS" = false ]; then
    echo "📋 Next steps:"
    echo "   No certificate found. Run SSL setup:"
    echo "   ./scripts/prod/enable-ssl.sh"
    echo ""
elif [ "$CERT_EXISTS" = true ] && [ "$SSL_CONFIG" = true ] && [ "$HTTPS_WORKS" = true ]; then
    echo "🎉 Everything is working!"
    echo "   Your site is available at: https://$DOMAIN"
    echo ""
fi
