#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "Stopping AI TradeMaestro production environment..."

docker-compose -f docker-compose.prod.yml down

echo "Services stopped successfully!"