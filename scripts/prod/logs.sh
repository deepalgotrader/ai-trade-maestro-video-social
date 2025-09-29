#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "Showing AI TradeMaestro production logs..."
echo "Press Ctrl+C to exit"
echo ""

docker-compose -f docker-compose.prod.yml logs -f