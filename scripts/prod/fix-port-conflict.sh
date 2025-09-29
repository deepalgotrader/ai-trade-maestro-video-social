#!/bin/bash

echo "=========================================="
echo "Fixing Port Conflicts (80 and 443)"
echo "=========================================="
echo ""

# Check what's using port 80
echo ">>> Checking what's using port 80..."
PORT_80=$(sudo lsof -i :80 -t 2>/dev/null || sudo netstat -tlnp | grep ':80 ' | awk '{print $7}' | cut -d'/' -f1 | head -1)

if [ ! -z "$PORT_80" ]; then
    echo "Port 80 is being used by process: $PORT_80"

    # Check if it's Apache
    if sudo systemctl list-units --full --all | grep -q apache2.service; then
        echo ">>> Stopping and disabling Apache2..."
        sudo systemctl stop apache2
        sudo systemctl disable apache2
        echo "Apache2 stopped and disabled"
    fi

    # Check if it's standalone Nginx
    if sudo systemctl list-units --full --all | grep -q nginx.service; then
        echo ">>> Stopping and disabling system Nginx..."
        sudo systemctl stop nginx
        sudo systemctl disable nginx
        echo "System Nginx stopped and disabled"
    fi

    # Check for other web servers
    if command -v httpd &> /dev/null; then
        echo ">>> Stopping httpd..."
        sudo systemctl stop httpd 2>/dev/null || sudo service httpd stop 2>/dev/null
        sudo systemctl disable httpd 2>/dev/null
    fi
else
    echo "Port 80 is free"
fi

# Check what's using port 443
echo ""
echo ">>> Checking what's using port 443..."
PORT_443=$(sudo lsof -i :443 -t 2>/dev/null || sudo netstat -tlnp | grep ':443 ' | awk '{print $7}' | cut -d'/' -f1 | head -1)

if [ ! -z "$PORT_443" ]; then
    echo "Port 443 is being used by process: $PORT_443"
else
    echo "Port 443 is free"
fi

# Kill any remaining processes on ports 80 and 443
echo ""
echo ">>> Killing any remaining processes on ports 80 and 443..."
sudo fuser -k 80/tcp 2>/dev/null || echo "No process found on port 80"
sudo fuser -k 443/tcp 2>/dev/null || echo "No process found on port 443"

echo ""
echo ">>> Verifying ports are now free..."
sleep 2

if sudo lsof -i :80 &> /dev/null; then
    echo "ERROR: Port 80 is still in use!"
    sudo lsof -i :80
    exit 1
else
    echo "✓ Port 80 is now free"
fi

if sudo lsof -i :443 &> /dev/null; then
    echo "ERROR: Port 443 is still in use!"
    sudo lsof -i :443
    exit 1
else
    echo "✓ Port 443 is now free"
fi

echo ""
echo "=========================================="
echo "Ports 80 and 443 are now available!"
echo "=========================================="
echo ""
echo "You can now run: ./scripts/prod/deploy.sh"