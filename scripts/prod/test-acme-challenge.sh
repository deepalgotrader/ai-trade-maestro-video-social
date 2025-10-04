#!/bin/bash

set -e

DOMAIN="aitrademaestro.ddns.net"

echo "=========================================="
echo "Testing ACME Challenge Path"
echo "=========================================="
echo ""

# 1. Create test file
echo ""
echo ">>> Creating test file in certbot webroot..."
docker exec aitrademaestro-nginx sh -c 'mkdir -p /var/www/certbot/.well-known/acme-challenge && echo "test123" > /var/www/certbot/.well-known/acme-challenge/test-file'

if [ $? -eq 0 ]; then
    echo "✓ Test file created in nginx container"
else
    echo "❌ Failed to create test file"
    exit 1
fi

# 2. Test locally
echo ""
echo ">>> Testing local access to ACME challenge..."
LOCAL_TEST=$(curl -s http://localhost/.well-known/acme-challenge/test-file 2>/dev/null || echo "FAILED")

if [ "$LOCAL_TEST" = "test123" ]; then
    echo "✓ ACME path works locally"
else
    echo "❌ ACME path NOT working locally"
    echo "   Expected: test123"
    echo "   Got: $LOCAL_TEST"
    echo ""
    echo "Checking nginx config..."
    docker exec aitrademaestro-nginx cat /etc/nginx/conf.d/app.conf | grep -A 5 "acme-challenge"
    exit 1
fi

# 3. Test publicly
echo ""
echo ">>> Testing public access to ACME challenge..."
PUBLIC_TEST=$(curl -s http://$DOMAIN/.well-known/acme-challenge/test-file 2>/dev/null || echo "FAILED")

if [ "$PUBLIC_TEST" = "test123" ]; then
    echo "✓ ACME path works publicly!"
    echo ""
    echo "=========================================="
    echo "✅ Everything is configured correctly!"
    echo "=========================================="
    echo ""
    echo "Let's Encrypt SHOULD be able to validate your domain."
    echo ""
    echo "Next step: Request certificate with verbose output"
    echo ""
else
    echo "❌ ACME path NOT accessible publicly"
    echo "   Expected: test123"
    echo "   Got: $PUBLIC_TEST"
    echo ""
    echo "This is why Let's Encrypt fails!"
    echo ""
    echo "Debug steps:"
    echo "  1. Check firewall: sudo ufw status"
    echo "  2. Test from external site: curl http://$DOMAIN/.well-known/acme-challenge/test-file"
    echo "  3. Check nginx logs: docker logs aitrademaestro-nginx --tail 20"
    exit 1
fi

# Cleanup
echo ">>> Cleaning up test file..."
docker exec aitrademaestro-nginx rm -f /var/www/certbot/.well-known/acme-challenge/test-file

echo ""
echo "Test completed successfully!"
echo ""
