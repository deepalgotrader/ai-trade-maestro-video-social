#!/bin/bash

set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "=========================================="
echo "AI TradeMaestro - Production Deployment"
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
echo ">>> Pulling latest changes from git (if needed)..."
if [ -d .git ]; then
    git pull origin main || echo "Warning: Could not pull from git"
fi

echo ""
echo ">>> Building Docker images..."
docker-compose -f docker-compose.prod.yml build --no-cache

echo ""
echo ">>> Starting services (without SSL initially)..."
# Start with initial nginx config (no SSL)
cp nginx/conf.d/app-initial.conf nginx/conf.d/app.conf.bak
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo ">>> Waiting for services to start..."
sleep 10

echo ""
echo ">>> Obtaining SSL certificate..."
./scripts/prod/init-ssl.sh

echo ""
echo ">>> Switching to SSL configuration..."
# Replace with SSL-enabled config
rm -f nginx/conf.d/app-initial.conf
docker-compose -f docker-compose.prod.yml restart nginx

echo ""
echo ">>> Running database migrations..."
docker-compose -f docker-compose.prod.yml exec -T backend alembic upgrade head

echo ""
echo "=========================================="
echo "Deployment Completed Successfully!"
echo "=========================================="
echo ""
echo "Your application is now live at:"
echo "  https://aitrademaestro.com"
echo "  https://www.aitrademaestro.com"
echo ""
echo "Useful commands:"
echo "  - View logs: ./scripts/prod/logs.sh"
echo "  - Stop services: ./scripts/prod/stop.sh"
echo "  - Restart services: ./scripts/prod/restart.sh"
echo ""