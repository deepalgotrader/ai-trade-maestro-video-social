#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Navigate to project root (two levels up from scripts/dev/)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "Stopping AI TradeMaestro development environment..."

docker-compose -f docker-compose.dev.yml down
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to stop services."
    exit 1
fi

echo "Services stopped successfully!"