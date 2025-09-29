#!/bin/bash

echo "Setting up AI TradeMaestro development environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed."
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: Docker Compose is not installed."
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "Installing frontend dependencies..."
cd frontend || exit 1
npm install
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install frontend dependencies."
    exit 1
fi

echo "Installing backend dependencies..."
cd ../backend || exit 1
pip3 install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install backend dependencies."
    exit 1
fi

cd ..

echo "Building Docker images..."
docker-compose -f docker-compose.dev.yml build
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build Docker images."
    exit 1
fi

echo "Setup completed successfully!"
echo "Run './start.sh' to start the development environment."