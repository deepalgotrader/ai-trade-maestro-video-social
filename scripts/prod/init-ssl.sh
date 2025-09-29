#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

DOMAIN="aitrademaestro.ddns.net"
EMAIL="${SSL_EMAIL:-admin@aitrademaestro.ddns.net}"

echo "=========================================="
echo "Initializing SSL Certificate"
echo "=========================================="
echo ""
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Check if certificate already exists
if [ -d "nginx/certbot/conf/live/$DOMAIN" ]; then
    echo "Certificate already exists for $DOMAIN"
    read -p "Do you want to renew it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    RENEW_FLAG="--force-renewal"
else
    RENEW_FLAG=""
fi

echo ">>> Requesting SSL certificate..."
docker-compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    $RENEW_FLAG \
    -d $DOMAIN

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "SSL Certificate obtained successfully!"
    echo "=========================================="
else
    echo ""
    echo "ERROR: Failed to obtain SSL certificate"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Ensure DNS records are pointing to this server"
    echo "  2. Check that ports 80 and 443 are open"
    echo "  3. Verify nginx is running: docker ps"
    echo "  4. Check nginx logs: docker logs aitrademaestro-nginx"
    exit 1
fi