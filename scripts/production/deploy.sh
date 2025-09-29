#!/bin/bash

echo "Deploying AI TradeMaestro to production..."

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "ERROR: Docker is not running."
    echo "Please start Docker first."
    exit 1
fi

# Navigate to project directory
cd /opt/ai-trademaestro || exit 1

# Pull latest code if git repository exists
if [ -d ".git" ]; then
    echo "Pulling latest code..."
    git pull origin main
fi

echo "Building production Docker images..."
docker-compose build --no-cache
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build production Docker images."
    exit 1
fi

echo "Starting production services..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start production services."
    exit 1
fi

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "Production deployment completed successfully!"
    echo "Application is running at: https://aitrademaestro.com"
    echo "API is running at: https://aitrademaestro.com/api"
    echo ""
    echo "To stop services, run './stop.sh'"
    echo "To view logs, run './logs.sh'"
else
    echo "ERROR: Some services failed to start. Check logs with './logs.sh'"
    exit 1
fi