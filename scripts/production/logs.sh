#!/bin/bash

echo "Showing AI TradeMaestro production logs..."

cd /opt/ai-trademaestro || exit 1

docker-compose logs -f