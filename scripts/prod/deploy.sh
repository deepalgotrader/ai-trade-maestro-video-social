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
echo ">>> Verifying Nginx configuration..."
if [ ! -f nginx/conf.d/app.conf ]; then
    echo "❌ nginx/conf.d/app.conf not found!"
    exit 1
fi
echo "✓ Nginx configuration ready"

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
    echo ""
    echo "Deployment completed but HTTP is not responding correctly."
    exit 1
fi

echo ""
echo "=========================================="
echo "Setting up SSL/HTTPS..."
echo "=========================================="
echo ""

# Run enable-ssl.sh automatically
if [ -f "$SCRIPT_DIR/enable-ssl.sh" ]; then
    echo ">>> Running SSL setup..."
    bash "$SCRIPT_DIR/enable-ssl.sh"
    SSL_EXIT=$?

    if [ $SSL_EXIT -eq 0 ]; then
        echo ""
        echo "=========================================="
        echo "🎉 Deployment Completed Successfully!"
        echo "=========================================="
        echo ""
        echo "🔒 Your application is now live and secure at:"
        echo "   https://aitrademaestro.ddns.net"
        echo ""
        echo "🌐 Available endpoints:"
        echo "   • Frontend: https://aitrademaestro.ddns.net"
        echo "   • API: https://aitrademaestro.ddns.net/api"
        echo "   • API Docs: https://aitrademaestro.ddns.net/docs"
        echo ""
        echo "✓ All HTTP traffic automatically redirects to HTTPS"
        echo "✓ SSL certificate auto-renews every 90 days"
        echo "✓ WhatsApp and other services can now open your links"
        echo ""
    else
        echo ""
        echo "⚠️  SSL setup encountered issues"
        echo ""
        echo "Your site is accessible at:"
        echo "  http://aitrademaestro.ddns.net"
        echo ""
        echo "To retry SSL setup manually:"
        echo "  ./scripts/prod/enable-ssl.sh"
        echo ""
    fi
else
    echo "⚠️  SSL script not found, skipping SSL setup"
    echo ""
    echo "Your application is accessible at:"
    echo "  http://aitrademaestro.ddns.net"
    echo ""
fi

echo "📊 Useful commands:"
echo "  - View logs: ./scripts/prod/logs.sh"
echo "  - Stop: ./scripts/prod/stop.sh"
echo "  - Restart: ./scripts/prod/restart.sh"
echo "  - Force SSL: ./scripts/prod/force-enable-ssl.sh"
echo ""