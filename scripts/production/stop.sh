#!/bin/bash

echo "Stopping AI TradeMaestro production environment..."

cd /opt/ai-trademaestro || exit 1

docker-compose down
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to stop production services."
    exit 1
fi

echo "Production services stopped successfully!"