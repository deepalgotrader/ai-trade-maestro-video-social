#!/bin/bash

set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "=========================================="
echo "AI TradeMaestro - HTTP-Only Deployment"
echo "=========================================="
echo ""

# Check if .env file exists
if [ ! -f .env.production ]; then
    echo "ERROR: .env.production file not found!"
    echo "Please create .env.production file with required environment variables"
    exit 1
fi

# Load environment variables
export $(grep -v '^#' .env.production | xargs)

echo ">>> Stopping existing services..."
docker-compose -f docker-compose.prod.yml down

echo ""
echo ">>> Building Docker images..."
docker-compose -f docker-compose.prod.yml build --no-cache

echo ""
echo ">>> Configuring Nginx for HTTP-only mode..."
# Use the initial config that doesn't require SSL
cp nginx/conf.d/app-initial.conf nginx/conf.d/app.conf

echo ""
echo ">>> Starting services..."
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo ">>> Waiting for services to start..."
sleep 10

echo ""
echo ">>> Running database migrations..."
docker-compose -f docker-compose.prod.yml exec -T backend alembic upgrade head || echo "Warning: Migration failed or no migrations to run"

echo ""
echo ">>> Checking service status..."
docker ps --filter "name=aitrademaestro"

echo ""
echo "=========================================="
echo "HTTP Deployment Completed!"
echo "=========================================="
echo ""
echo "Your application is now accessible at:"
echo "  http://aitrademaestro.ddns.net"
echo ""
echo "⚠️  NOTE: The site is currently running on HTTP (not secure)"
echo ""
echo "To test locally:"
echo "  curl http://localhost"
echo "  curl http://aitrademaestro.ddns.net"
echo ""
echo "Next steps:"
echo "  1. Verify the site works on HTTP"
echo "  2. Run './scripts/prod/add-ssl.sh' to add SSL/HTTPS"
echo ""
echo "Useful commands:"
echo "  - View logs: ./scripts/prod/logs.sh"
echo "  - Stop services: ./scripts/prod/stop.sh"
echo "  - Restart services: ./scripts/prod/restart.sh"
echo ""