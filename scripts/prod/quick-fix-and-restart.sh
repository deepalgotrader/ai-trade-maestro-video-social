#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "=========================================="
echo "Quick Fix and Restart"
echo "=========================================="
echo ""

# Pull latest changes
echo ">>> Pulling latest changes..."
git pull origin main

echo ""
echo ">>> Copying correct nginx configuration..."
cp nginx/conf.d/app-initial.conf nginx/conf.d/app.conf

echo ""
echo ">>> Restarting Nginx..."
docker-compose -f docker-compose.prod.yml restart nginx

echo ""
echo ">>> Waiting for Nginx to restart..."
sleep 5

echo ""
echo ">>> Testing HTTP connectivity..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    echo "✓ HTTP is working!"
else
    echo "⚠️  HTTP returned non-200 status, checking response..."
    curl -I http://localhost
fi

echo ""
echo "=========================================="
echo "Fix Applied!"
echo "=========================================="
echo ""
echo "Test your site:"
echo "  curl http://localhost"
echo "  curl http://aitrademaestro.ddns.net"
echo "  Or open in browser: http://aitrademaestro.ddns.net"
echo ""