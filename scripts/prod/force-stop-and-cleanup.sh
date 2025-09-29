#!/bin/bash

echo "=========================================="
echo "Force Stop All Services and Cleanup"
echo "=========================================="
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo ">>> Stopping all Docker containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || echo "No containers to stop"

echo ""
echo ">>> Stopping any remaining AI TradeMaestro containers..."
docker stop $(docker ps -a -q --filter "name=aitrademaestro") 2>/dev/null || echo "No aitrademaestro containers found"
docker rm $(docker ps -a -q --filter "name=aitrademaestro") 2>/dev/null || echo "No aitrademaestro containers to remove"

echo ""
echo ">>> Checking for processes using ports 80 and 443..."

# Function to kill process on a port
kill_port() {
    PORT=$1
    echo "Checking port $PORT..."

    # Find PID using the port
    PID=$(sudo lsof -ti:$PORT 2>/dev/null)

    if [ ! -z "$PID" ]; then
        echo "  Found process $PID using port $PORT"
        sudo kill -9 $PID 2>/dev/null || echo "  Could not kill process $PID"
        sleep 1
    else
        echo "  Port $PORT is free"
    fi
}

# Kill processes on port 80 and 443
kill_port 80
kill_port 443

echo ""
echo ">>> Stopping system web servers..."

# Stop Apache
if systemctl is-active --quiet apache2 2>/dev/null; then
    echo "Stopping Apache2..."
    sudo systemctl stop apache2
    sudo systemctl disable apache2
fi

# Stop system Nginx
if systemctl is-active --quiet nginx 2>/dev/null; then
    echo "Stopping system Nginx..."
    sudo systemctl stop nginx
    sudo systemctl disable nginx
fi

# Force kill with fuser
echo ""
echo ">>> Force killing any remaining processes on ports 80 and 443..."
sudo fuser -k 80/tcp 2>/dev/null || echo "No process on port 80"
sudo fuser -k 443/tcp 2>/dev/null || echo "No process on port 443"

sleep 2

echo ""
echo ">>> Final verification..."
if sudo lsof -i :80 &> /dev/null; then
    echo "❌ WARNING: Port 80 is still in use:"
    sudo lsof -i :80
    echo ""
    echo "You may need to manually stop the service:"
    echo "  sudo lsof -i :80    # to see what's using it"
    echo "  sudo kill -9 <PID>  # to kill it"
else
    echo "✓ Port 80 is free"
fi

if sudo lsof -i :443 &> /dev/null; then
    echo "❌ WARNING: Port 443 is still in use:"
    sudo lsof -i :443
    echo ""
    echo "You may need to manually stop the service:"
    echo "  sudo lsof -i :443   # to see what's using it"
    echo "  sudo kill -9 <PID>  # to kill it"
else
    echo "✓ Port 443 is free"
fi

echo ""
echo "=========================================="
echo "Cleanup Complete!"
echo "=========================================="
echo ""
echo "Now you can run: ./scripts/prod/deploy.sh"