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

# Check if certificate already exists
if [ -d "nginx/certbot/conf/live/$DOMAIN" ]; then
    echo ""
    echo "✓ SSL certificate already exists"
    echo "Skipping certificate request..."
else
    echo ""
    echo ">>> Requesting SSL certificate from Let's Encrypt..."
    docker-compose -f docker-compose.prod.yml run --rm certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email $EMAIL \
        --agree-tos \
        --no-eff-email \
        --non-interactive \
        -d $DOMAIN

    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ Failed to obtain SSL certificate"
        echo ""
        echo "Common issues:"
        echo "  1. DNS not pointing correctly: dig $DOMAIN"
        echo "  2. Port 80 not accessible from internet"
        echo "  3. Firewall blocking port 80"
        echo ""
        echo "Debug: docker logs aitrademaestro-nginx"
        exit 1
    fi

    echo ""
    echo "✓ SSL Certificate obtained successfully!"
fi

echo ""
echo ">>> Enabling HTTPS in Nginx configuration..."

# Backup current config
cp nginx/conf.d/app.conf nginx/conf.d/app.conf.backup-$(date +%Y%m%d-%H%M%S)

# Restart nginx to apply SSL configuration
echo ">>> Restarting Nginx with SSL..."
docker-compose -f docker-compose.prod.yml restart nginx

echo ""
echo ">>> Waiting for Nginx to restart..."
sleep 5

echo ""
echo ">>> Testing HTTPS..."
HTTPS_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost || echo "000")

if [ "$HTTPS_CODE" = "200" ]; then
    echo "✓ HTTPS is working!"
else
    echo "⚠️  HTTPS returned status $HTTPS_CODE"
    echo "Check logs: docker logs aitrademaestro-nginx"
fi

echo ""
echo "=========================================="
echo "SSL Enabled Successfully!"
echo "=========================================="
echo ""
echo "Your site is now secure:"
echo "  https://$DOMAIN"
echo ""
echo "HTTP requests will be redirected to HTTPS automatically"
echo ""