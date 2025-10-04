#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

DOMAIN="aitrademaestro.ddns.net"

echo "=========================================="
echo "Quick SSL Fix & Setup"
echo "=========================================="
echo ""

# 1. Create directories
echo ">>> Creating certbot directories..."
mkdir -p nginx/certbot/www/.well-known/acme-challenge
mkdir -p nginx/certbot/conf
chmod -R 755 nginx/certbot/www

echo "✓ Directories created"

# 2. Restart nginx with new volume configuration
echo ""
echo ">>> Restarting nginx with read-write access to certbot webroot..."
docker-compose -f docker-compose.prod.yml up -d --force-recreate nginx

echo ""
echo ">>> Waiting for nginx to start..."
sleep 5

# 3. Test ACME path
echo ""
echo ">>> Testing ACME challenge path..."
docker exec aitrademaestro-nginx sh -c 'mkdir -p /var/www/certbot/.well-known/acme-challenge && echo "test123" > /var/www/certbot/.well-known/acme-challenge/test-file'

LOCAL_TEST=$(curl -s http://localhost/.well-known/acme-challenge/test-file 2>/dev/null || echo "FAILED")

if [ "$LOCAL_TEST" = "test123" ]; then
    echo "✓ ACME path is now writable and accessible!"
else
    echo "❌ ACME path still not working"
    echo "   Got: $LOCAL_TEST"
    exit 1
fi

# 4. Test public access
echo ""
echo ">>> Testing public ACME access..."
PUBLIC_TEST=$(curl -s http://$DOMAIN/.well-known/acme-challenge/test-file 2>/dev/null || echo "FAILED")

if [ "$PUBLIC_TEST" = "test123" ]; then
    echo "✓ ACME path accessible publicly!"
else
    echo "⚠️  Public access returned: $PUBLIC_TEST"
    echo "   (May be network issue, continuing anyway)"
fi

# Cleanup test file
docker exec aitrademaestro-nginx rm -f /var/www/certbot/.well-known/acme-challenge/test-file

# 5. Request certificate
echo ""
echo "=========================================="
echo "Requesting SSL Certificate"
echo "=========================================="
echo ""

if [ -f .env.production ]; then
    export $(grep -v '^#' .env.production | xargs)
    EMAIL="${SSL_EMAIL:-admin@aitrademaestro.ddns.net}"
else
    EMAIL="admin@aitrademaestro.ddns.net"
fi

echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""
echo "⏳ Requesting certificate from Let's Encrypt..."
echo ""

docker-compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN

CERT_EXIT=$?

if [ $CERT_EXIT -eq 0 ]; then
    echo ""
    echo "✓ Certificate obtained successfully!"

    # Check if certificate exists
    if [ -d "nginx/certbot/conf/live/$DOMAIN" ]; then
        echo "✓ Certificate files confirmed"

        # Show certificate details
        echo ""
        echo "Certificate details:"
        openssl x509 -in "nginx/certbot/conf/live/$DOMAIN/cert.pem" -noout -dates -subject 2>/dev/null || echo "Cannot read certificate details"

        # 6. Restart nginx to load certificates
        echo ""
        echo ">>> Restarting nginx to enable HTTPS..."
        docker-compose -f docker-compose.prod.yml restart nginx

        sleep 5

        # 7. Test HTTPS
        echo ""
        echo ">>> Testing HTTPS..."
        HTTPS_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost 2>/dev/null || echo "000")

        if [ "$HTTPS_CODE" = "200" ]; then
            echo "✓ HTTPS is working! (status: $HTTPS_CODE)"

            echo ""
            echo "=========================================="
            echo "🎉 SSL Successfully Enabled!"
            echo "=========================================="
            echo ""
            echo "🔒 Your site is now secure at:"
            echo "   https://$DOMAIN"
            echo ""
            echo "✓ HTTP automatically redirects to HTTPS"
            echo "✓ Certificate auto-renews every 90 days"
            echo "✓ WhatsApp and social media compatible"
            echo ""

        else
            echo "⚠️  HTTPS returned status: $HTTPS_CODE"
            echo ""
            echo "Certificate installed but HTTPS not responding."
            echo "Check nginx config and logs:"
            echo "  docker exec aitrademaestro-nginx nginx -t"
            echo "  docker logs aitrademaestro-nginx --tail 20"
        fi

    else
        echo "⚠️  Certificate directory not found after request"
    fi

else
    echo ""
    echo "❌ Certificate request failed (exit code: $CERT_EXIT)"
    echo ""
    echo "Check certbot logs for details"
fi

echo ""
