#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

DOMAIN="aitrademaestro.ddns.net"

echo "=========================================="
echo "Force Enable SSL/HTTPS"
echo "=========================================="
echo ""
echo "Domain: $DOMAIN"
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

echo "✓ HTTP is working (status: $HTTP_CODE)"

# List existing certificates
echo ""
echo ">>> Checking certificates in container..."
docker-compose -f docker-compose.prod.yml run --rm certbot certificates 2>&1 | grep -A 5 "Certificate Name\|Domains\|Expiry Date" || echo "No certificates found or unable to check"

# Check if SSL config is ready
echo ""
echo ">>> Verifying Nginx SSL configuration..."
if grep -q "listen 443 ssl" nginx/conf.d/app.conf; then
    echo "✓ SSL configuration found in app.conf"

    # Show SSL certificate paths from config
    echo ""
    echo ">>> SSL Certificate paths in config:"
    grep "ssl_certificate" nginx/conf.d/app.conf | head -3
else
    echo "❌ SSL configuration not found in app.conf"
    exit 1
fi

# Restart nginx to apply configuration
echo ""
echo ">>> Restarting Nginx to apply SSL..."
docker-compose -f docker-compose.prod.yml restart nginx

echo ""
echo ">>> Waiting for Nginx to restart..."
sleep 5

# Test HTTPS locally
echo ""
echo ">>> Testing HTTPS locally..."
HTTPS_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost 2>/dev/null || echo "000")

if [ "$HTTPS_CODE" = "200" ]; then
    echo "✓ HTTPS is working locally (status: $HTTPS_CODE)"
else
    echo "⚠️  HTTPS returned status $HTTPS_CODE locally"
    echo ""
    echo ">>> Checking Nginx error logs..."
    docker logs aitrademaestro-nginx --tail 20 2>&1 | grep -i "error\|ssl\|certificate" || echo "No SSL errors found in logs"
fi

# Test public HTTPS
echo ""
echo ">>> Testing public HTTPS access..."
PUBLIC_HTTPS=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN 2>/dev/null || echo "000")

if [ "$PUBLIC_HTTPS" = "200" ]; then
    echo "✓ Public HTTPS is working! (status: $PUBLIC_HTTPS)"

    echo ""
    echo "=========================================="
    echo "🎉 SSL is Active!"
    echo "=========================================="
    echo ""
    echo "🔒 Your site is now secure at:"
    echo "   https://$DOMAIN"
    echo ""
    echo "🌐 Test URLs:"
    echo "   • Frontend: https://$DOMAIN"
    echo "   • API: https://$DOMAIN/api"
    echo "   • API Docs: https://$DOMAIN/docs"
    echo ""
    echo "✅ All done!"

elif [ "$PUBLIC_HTTPS" = "000" ]; then
    echo "⚠️  Cannot connect to public HTTPS (network error)"
    echo ""
    echo "Possible issues:"
    echo "  1. Firewall blocking port 443"
    echo "  2. DNS not pointing to this server"
    echo "  3. SSL certificate not valid"
    echo ""
    echo "Debug steps:"
    echo "  1. Check firewall: sudo ufw status"
    echo "  2. Check DNS: dig $DOMAIN"
    echo "  3. Check certificate: docker-compose -f docker-compose.prod.yml run --rm certbot certificates"
    echo "  4. Check nginx logs: docker logs aitrademaestro-nginx --tail 50"

else
    echo "⚠️  Public HTTPS returned status $PUBLIC_HTTPS"
    echo ""
    echo "The server is responding but with an error status."
    echo "Check nginx logs: docker logs aitrademaestro-nginx --tail 50"
fi

echo ""