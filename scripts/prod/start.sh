#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "Starting AI TradeMaestro production environment..."

# Check if .env file exists
if [ ! -f .env.production ]; then
    echo "ERROR: .env.production file not found!"
    exit 1
fi

export $(grep -v '^#' .env.production | xargs)

docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "Services started successfully!"
echo "  - Frontend: https://aitrademaestro.com"
echo "  - Backend API: https://aitrademaestro.com/api"
echo "  - Backend Docs: https://aitrademaestro.com/docs"
echo ""
echo "To view logs: ./scripts/prod/logs.sh"