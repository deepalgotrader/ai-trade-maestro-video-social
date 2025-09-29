#!/bin/bash

echo "Stopping AI TradeMaestro development environment..."

docker-compose -f docker-compose.dev.yml down
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to stop services."
    exit 1
fi

echo "Services stopped successfully!"