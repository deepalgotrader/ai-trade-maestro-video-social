#!/bin/bash

# Quick fix for SSL certificate configuration

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Fixing SSL certificate configuration...${NC}"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

# Copy updated nginx config
echo ">>> Updating nginx configuration..."
sudo cp "$PROJECT_ROOT/nginx-native-config/aitrademaestro.conf" /etc/nginx/sites-available/aitrademaestro

# Test nginx config
echo ">>> Testing nginx configuration..."
sudo nginx -t

if [ $? -ne 0 ]; then
    echo "❌ Nginx configuration test failed!"
    exit 1
fi

# Reload nginx
echo ">>> Reloading nginx..."
sudo systemctl reload nginx

echo ""
echo -e "${GREEN}✅ SSL configuration updated!${NC}"
echo ""
echo "Testing HTTPS..."
sleep 2

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://aitrademaestro.ddns.net 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ HTTPS is working! (HTTP $HTTP_CODE)${NC}"
    echo ""
    echo "Your app is now live at:"
    echo "  https://aitrademaestro.ddns.net"
else
    echo "⚠️  HTTPS returned HTTP $HTTP_CODE"
    echo ""
    echo "Check logs:"
    echo "  sudo tail -f /var/log/nginx/aitrademaestro_error.log"
fi

echo ""
