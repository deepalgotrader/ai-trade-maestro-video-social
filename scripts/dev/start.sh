#!/bin/bash

echo "Starting AI TradeMaestro development environment..."

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "ERROR: Docker is not running."
    echo "Please start Docker first."
    exit 1
fi

echo "Starting services..."
docker-compose -f docker-compose.dev.yml up -d
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start services."
    exit 1
fi

echo "Services started successfully!"
echo "Frontend: http://localhost:3000"
echo "Backend API: http://localhost:8000"
echo "Backend Docs: http://localhost:8000/docs"
echo ""
echo "To stop services, run './stop.sh'"
echo "To view logs, run './logs.sh'"