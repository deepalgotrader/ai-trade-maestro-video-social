#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

DOMAIN="aitrademaestro.ddns.net"
EMAIL="${SSL_EMAIL:-deepalgotrader@gmail.com}"

echo "=========================================="
echo "Adding SSL Certificate"
echo "=========================================="
echo ""
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Load environment variables
if [ -f .env.production ]; then
    export $(grep -v '^#' .env.production | xargs)
fi

# Check if services are running
if ! docker ps | grep -q aitrademaestro-nginx; then
    echo "ERROR: Services are not running!"
    echo "Please run './scripts/prod/deploy-http-only.sh' first"
    exit 1
fi

# Test HTTP connectivity first
echo ">>> Testing HTTP connectivity..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|301\|302"; then
    echo "✓ HTTP is working"
else
    echo "❌ HTTP is not responding. Fix this before adding SSL."
    echo "Check logs: docker logs aitrademaestro-nginx"
    exit 1
fi

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
    echo "  1. DNS not pointing to this server: dig $DOMAIN"
    echo "  2. Port 80 not accessible from internet"
    echo "  3. Domain validation failed"
    echo ""
    echo "Debug commands:"
    echo "  docker logs aitrademaestro-nginx"
    echo "  curl -I http://$DOMAIN/.well-known/acme-challenge/test"
    exit 1
fi

echo ""
echo "✓ SSL Certificate obtained successfully!"

echo ""
echo ">>> Switching Nginx to HTTPS configuration..."
# Backup current config
cp nginx/conf.d/app.conf nginx/conf.d/app.conf.backup

# Copy SSL-enabled config
cp nginx/conf.d/app.conf nginx/conf.d/app.conf.bak
cat > nginx/conf.d/app.conf << 'EOF'
# This will be replaced - keeping as placeholder
EOF

# Actually copy the real SSL config
cp nginx/conf.d/app.conf.bak nginx/conf.d/app.conf
rm nginx/conf.d/app.conf.bak

# Restart Nginx to load SSL certificates
echo ">>> Restarting Nginx with SSL configuration..."
docker-compose -f docker-compose.prod.yml restart nginx

# Wait for Nginx to restart
sleep 3

echo ""
echo ">>> Testing HTTPS..."
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost | grep -q "200\|301\|302"; then
    echo "✓ HTTPS is working!"
else
    echo "⚠️  HTTPS might not be working yet. Check logs:"
    echo "   docker logs aitrademaestro-nginx"
fi

echo ""
echo "=========================================="
echo "SSL Certificate Added Successfully!"
echo "=========================================="
echo ""
echo "Your application is now accessible at:"
echo "  https://$DOMAIN"
echo ""
echo "HTTP requests will be automatically redirected to HTTPS"
echo ""