#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

# Load environment variables
if [ -f .env.production ]; then
    export $(grep -v '^#' .env.production | xargs)
fi

echo ">>> Restarting nginx..."
docker-compose -f docker-compose.prod.yml restart nginx

echo ""
echo ">>> Waiting for nginx to start..."
sleep 5

echo ""
echo ">>> Testing nginx..."
docker ps | grep aitrademaestro-nginx

echo ""
echo ">>> Nginx logs..."
docker logs aitrademaestro-nginx --tail 10

echo ""
echo ">>> Testing HTTP..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost || echo "000")
echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Nginx is working!"
else
    echo "⚠️  HTTP returned $HTTP_CODE"
fi

echo ""
