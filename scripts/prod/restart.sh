#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "Restarting AI TradeMaestro production environment..."

if [ ! -f .env.production ]; then
    echo "ERROR: .env.production file not found!"
    exit 1
fi

export $(grep -v '^#' .env.production | xargs)

docker-compose -f docker-compose.prod.yml restart

echo "Services restarted successfully!"