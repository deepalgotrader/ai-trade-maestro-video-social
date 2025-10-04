#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

DOMAIN="aitrademaestro.ddns.net"

if [ -f .env.production ]; then
    export $(grep -v '^#' .env.production | xargs)
    EMAIL="${SSL_EMAIL:-admin@aitrademaestro.ddns.net}"
else
    EMAIL="admin@aitrademaestro.ddns.net"
fi

echo "=========================================="
echo "Enabling SSL/HTTPS (STAGING - For Testing)"
echo "=========================================="
echo ""
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""
echo "⚠️  Using Let's Encrypt STAGING server"
echo "   This creates TEST certificates (not trusted by browsers)"
echo "   Use this to debug issues without rate limits"
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
    exit 1
fi

echo "✓ HTTP is working"

# Request staging certificate
echo ""
echo ">>> Requesting STAGING SSL certificate..."
echo "⏳ This may take 30-60 seconds..."
echo ""

docker-compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --non-interactive \
    --staging \
    --force-renewal \
    -d $DOMAIN

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✓ STAGING Certificate obtained!"
    echo ""
    echo "This means your server is REACHABLE from internet!"
    echo "Let's Encrypt can validate your domain."
    echo ""
    echo "Next steps:"
    echo "  1. Remove staging certificate:"
    echo "     sudo rm -rf nginx/certbot/conf/live/$DOMAIN"
    echo "     sudo rm -rf nginx/certbot/conf/archive/$DOMAIN"
    echo "     sudo rm -rf nginx/certbot/conf/renewal/$DOMAIN.conf"
    echo ""
    echo "  2. Get REAL certificate:"
    echo "     ./scripts/prod/enable-ssl.sh"
else
    echo ""
    echo "❌ Failed to obtain STAGING certificate"
    echo ""
    echo "This means your server is NOT publicly accessible!"
    echo ""
    echo "Run diagnostics:"
    echo "  ./scripts/prod/diagnose-ssl.sh"
fi

echo ""
