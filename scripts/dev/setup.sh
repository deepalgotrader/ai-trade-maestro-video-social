#!/bin/bash

set -e  # Exit on error

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Navigate to project root (two levels up from scripts/dev/)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

echo "=========================================="
echo "AI TradeMaestro - Complete Setup Script"
echo "=========================================="
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "ERROR: Cannot detect OS"
    exit 1
fi

echo "Detected OS: $OS"
echo ""

# Update system packages
echo ">>> Updating system packages..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo apt-get update
    sudo apt-get install -y curl wget gnupg2 software-properties-common apt-transport-https ca-certificates
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    sudo yum update -y
    sudo yum install -y curl wget
else
    echo "WARNING: Unsupported OS. Attempting to continue..."
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo ">>> Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker installed successfully!"
else
    echo ">>> Docker already installed: $(docker --version)"
fi

# Start Docker service
echo ">>> Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo ">>> Docker Compose not found. Installing Docker Compose..."

    # Try to install as Docker plugin first
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt-get install -y docker-compose-plugin
    else
        # Fallback to standalone installation
        DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    echo "Docker Compose installed successfully!"
else
    echo ">>> Docker Compose already installed: $(docker-compose --version)"
fi

# Install Node.js and npm if not present
if ! command -v node &> /dev/null; then
    echo ">>> Node.js not found. Installing Node.js LTS..."

    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
        sudo yum install -y nodejs
    else
        echo "ERROR: Cannot install Node.js automatically for this OS"
        exit 1
    fi

    echo "Node.js installed successfully!"
else
    echo ">>> Node.js already installed: $(node --version)"
    echo ">>> npm already installed: $(npm --version)"
fi

# Install Python 3 and pip if not present
if ! command -v python3 &> /dev/null; then
    echo ">>> Python 3 not found. Installing Python 3..."

    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt-get install -y python3 python3-pip python3-venv
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        sudo yum install -y python3 python3-pip
    else
        echo "ERROR: Cannot install Python 3 automatically for this OS"
        exit 1
    fi

    echo "Python 3 installed successfully!"
else
    echo ">>> Python 3 already installed: $(python3 --version)"
fi

# Check pip3
if ! command -v pip3 &> /dev/null; then
    echo ">>> pip3 not found. Installing pip3..."

    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt-get install -y python3-pip
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        sudo yum install -y python3-pip
    fi
fi

echo ">>> pip3 installed: $(pip3 --version)"

echo ""
echo "=========================================="
echo "Installing Project Dependencies"
echo "=========================================="
echo ""

echo ">>> Installing frontend dependencies..."
cd frontend || exit 1
npm install
echo "Frontend dependencies installed successfully!"

echo ""
echo ">>> Installing backend dependencies..."
cd ../backend || exit 1

# Upgrade pip first
pip3 install --upgrade pip

# Install Python dependencies
pip3 install -r requirements.txt
echo "Backend dependencies installed successfully!"

cd ..

echo ""
echo ">>> Creating necessary directories..."
mkdir -p logs
mkdir -p data
echo "Directories created!"

echo ""
echo ">>> Building Docker images..."
docker-compose -f docker-compose.dev.yml build
echo "Docker images built successfully!"

echo ""
echo "=========================================="
echo "Setup Completed Successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Configure your environment variables in .env file"
echo "  2. Run './scripts/dev/start.sh' to start the development environment"
echo ""
echo "Note: If you installed Docker for the first time, you may need to:"
echo "  - Log out and log back in for group changes to take effect"
echo "  - Or run: newgrp docker"
echo ""