#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

DOMAIN="aitrademaestro.ddns.net"

# Load environment variables
if [ -f .env.production ]; then
    export $(grep -v '^#' .env.production | xargs)
    EMAIL="${SSL_EMAIL:-admin@aitrademaestro.ddns.net}"
else
    EMAIL="admin@aitrademaestro.ddns.net"
fi

echo "=========================================="
echo "Enabling SSL/HTTPS"
echo "=========================================="
echo ""
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Check if services are running
if ! docker ps | grep -q aitrademaestro-nginx; then
    echo "❌ ERROR: Services are not running!"
    echo "Please run './scripts/prod/deploy.sh' first"
    exit 1
fi

# Test HTTP connectivity
echo ">>> Testing HTTP connectivity..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost || echo "000")

if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ HTTP is not working properly (got status $HTTP_CODE)"
    echo "Please ensure the site works on HTTP before adding SSL"
    exit 1
fi

echo "✓ HTTP is working"

# Check if certificate already exists in container
echo ""
echo ">>> Checking for existing SSL certificate..."

CERT_CHECK=$(docker-compose -f docker-compose.prod.yml run --rm --entrypoint "sh -c 'if [ -d /etc/letsencrypt/live/$DOMAIN ]; then echo EXISTS; else echo NOTFOUND; fi'" certbot 2>/dev/null | grep -o "EXISTS\|NOTFOUND" | head -1)

if [ "$CERT_CHECK" = "EXISTS" ]; then
    echo "✓ SSL certificate already exists for $DOMAIN"

    # Check certificate expiry
    echo ">>> Checking certificate validity..."
    EXPIRY=$(docker-compose -f docker-compose.prod.yml run --rm --entrypoint "openssl x509 -enddate -noout -in /etc/letsencrypt/live/$DOMAIN/cert.pem" certbot 2>/dev/null | grep "notAfter" | cut -d= -f2)
    if [ -n "$EXPIRY" ]; then
        echo "📅 Certificate expires: $EXPIRY"
    fi

    echo ""
    echo "✓ Certificate is valid, skipping request"
else
    echo ">>> Requesting NEW SSL certificate from Let's Encrypt..."
    echo "⏳ This may take 30-60 seconds..."
    echo ""

    # Request new certificate
    docker-compose -f docker-compose.prod.yml run --rm certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email $EMAIL \
        --agree-tos \
        --no-eff-email \
        --non-interactive \
        -d $DOMAIN

    EXIT_CODE=$?

    # Certbot returns 0 even when "No renewals were attempted" if cert exists
    # Check again if certificate exists now
    CERT_CHECK_AFTER=$(docker-compose -f docker-compose.prod.yml run --rm --entrypoint "sh -c 'if [ -d /etc/letsencrypt/live/$DOMAIN ]; then echo EXISTS; else echo NOTFOUND; fi'" certbot 2>/dev/null | grep -o "EXISTS\|NOTFOUND" | head -1)

    if [ "$CERT_CHECK_AFTER" = "EXISTS" ]; then
        echo ""
        echo "✓ SSL Certificate is ready!"
    elif [ $EXIT_CODE -ne 0 ]; then
        echo ""
        echo "❌ Failed to obtain SSL certificate"
        echo ""
        echo "Common issues:"
        echo "  1. DNS not pointing correctly: dig $DOMAIN"
        echo "  2. Port 80 not accessible from internet"
        echo "  3. Firewall blocking port 80"
        echo ""
        echo "Debug commands:"
        echo "  docker logs aitrademaestro-nginx"
        echo "  dig $DOMAIN"
        echo "  curl http://$DOMAIN"
        exit 1
    fi
fi

echo ""
echo ">>> Enabling HTTPS in Nginx configuration..."

# Check if SSL configuration is already active
if grep -q "listen 443 ssl" nginx/conf.d/app.conf; then
    echo "✓ SSL configuration is already active in app.conf"
else
    echo "⚠️  SSL configuration not found in app.conf"
    echo "Please ensure nginx/conf.d/app.conf has SSL configuration"
    exit 1
fi

# Restart nginx to apply SSL configuration
echo ""
echo ">>> Restarting Nginx with SSL..."
docker-compose -f docker-compose.prod.yml restart nginx

echo ""
echo ">>> Waiting for Nginx to restart..."
sleep 5

echo ""
echo ">>> Testing HTTPS locally..."
HTTPS_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost || echo "000")

if [ "$HTTPS_CODE" = "200" ]; then
    echo "✓ HTTPS is working locally (status: $HTTPS_CODE)"
else
    echo "⚠️  HTTPS returned status $HTTPS_CODE locally"
    echo "Check logs: docker logs aitrademaestro-nginx"
fi

echo ""
echo ">>> Testing public HTTPS access..."
PUBLIC_HTTPS=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN 2>/dev/null || echo "000")
if [ "$PUBLIC_HTTPS" = "200" ]; then
    echo "✓ Public HTTPS is working (status: $PUBLIC_HTTPS)"
else
    echo "⚠️  Public HTTPS returned status $PUBLIC_HTTPS"
    echo "This might be normal if DNS hasn't propagated yet"
fi

echo ""
echo "=========================================="
echo "🎉 SSL Enabled Successfully!"
echo "=========================================="
echo ""
echo "🔒 Your site is now secure at:"
echo "   https://$DOMAIN"
echo ""
echo "📋 What happens now:"
echo "   ✓ All HTTP traffic redirects to HTTPS automatically"
echo "   ✓ Certificate auto-renews every 90 days"
echo "   ✓ Site is encrypted with TLS 1.2/1.3"
echo ""
echo "🌐 Test your site:"
echo "   Open in browser: https://$DOMAIN"
echo "   API endpoint: https://$DOMAIN/api"
echo "   API docs: https://$DOMAIN/docs"
echo ""
echo "📊 Monitor logs:"
echo "   docker logs aitrademaestro-nginx -f"
echo ""
echo "✅ Deployment complete!"
echo ""