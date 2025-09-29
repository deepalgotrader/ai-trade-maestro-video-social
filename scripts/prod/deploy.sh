#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "=========================================="
echo "AI TradeMaestro - Production Deployment"
echo "=========================================="
echo ""

# Check if .env file exists
if [ ! -f .env.production ]; then
    echo "❌ ERROR: .env.production file not found!"
    echo "Please create .env.production file with required environment variables"
    echo ""
    echo "Example:"
    echo "  cp .env.production.example .env.production"
    echo "  nano .env.production"
    exit 1
fi

# Load environment variables
export $(grep -v '^#' .env.production | xargs)

echo ">>> Stopping existing services..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || echo "No services to stop"

echo ""
echo ">>> Building Docker images..."
docker-compose -f docker-compose.prod.yml build --no-cache

echo ""
echo ">>> Copying correct Nginx configuration..."
cp nginx/conf.d/app-initial.conf nginx/conf.d/app.conf

echo ""
echo ">>> Starting services..."
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo ">>> Waiting for services to start..."
sleep 10

echo ""
echo ">>> Running database migrations..."
docker-compose -f docker-compose.prod.yml exec -T backend alembic upgrade head || echo "⚠️  Migrations failed or no migrations to run"

echo ""
echo ">>> Checking service status..."
docker ps --filter "name=aitrademaestro" --format "table {{.Names}}\t{{.Status}}"

echo ""
echo ">>> Testing HTTP..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ HTTP is working!"
else
    echo "⚠️  HTTP returned status $HTTP_CODE"
    echo "Check logs: docker logs aitrademaestro-nginx"
fi

echo ""
echo "=========================================="
echo "Deployment Completed!"
echo "=========================================="
echo ""
echo "Your application is accessible at:"
echo "  http://aitrademaestro.ddns.net"
echo ""
echo "📌 Next step: Enable HTTPS"
echo "  Run: ./scripts/prod/enable-ssl.sh"
echo ""
echo "Useful commands:"
echo "  - Enable SSL: ./scripts/prod/enable-ssl.sh"
echo "  - View logs: ./scripts/prod/logs.sh"
echo "  - Stop: ./scripts/prod/stop.sh"
echo "  - Restart: ./scripts/prod/restart.sh"
echo ""