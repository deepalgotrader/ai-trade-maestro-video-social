#!/bin/bash

# ====================================================================
# AI TradeMaestro - Complete Setup & Deployment Script
# ====================================================================
# This script handles everything from zero to production with HTTPS
# Run on your VPS: ./scripts/prod/complete-setup.sh
# ====================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOMAIN="aitrademaestro.ddns.net"
EMAIL="${SSL_EMAIL:-deepalgotrader@gmail.com}"

# ====================================================================
# Helper Functions
# ====================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 is not installed"
        return 1
    fi
    log_success "$1 is installed"
    return 0
}

# ====================================================================
# Main Script
# ====================================================================

echo ""
echo "===================================================================="
echo "   AI TradeMaestro - Complete Setup & Deployment"
echo "===================================================================="
echo ""
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# ====================================================================
# Step 1: Environment Check
# ====================================================================

log_info "Step 1: Checking environment..."
echo ""

# Check if on VPS (has native nginx)
if [ ! -f /etc/nginx/nginx.conf ]; then
    log_error "Native nginx not found. Are you on the VPS?"
    exit 1
fi
log_success "Native nginx detected"

# Check required commands
check_command docker || exit 1
check_command docker-compose || exit 1
check_command certbot || log_warning "certbot not installed (will install)"
check_command curl || exit 1

echo ""

# ====================================================================
# Step 2: Project Directory Check
# ====================================================================

log_info "Step 2: Checking project directory..."
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT" || exit 1

log_success "Working directory: $PROJECT_ROOT"

# Check .env.production
if [ ! -f .env.production ]; then
    log_error ".env.production not found!"
    log_info "Creating from template..."
    cp .env.production.example .env.production
    log_warning "Please edit .env.production with your credentials!"
    log_warning "Then run this script again."
    exit 1
fi

log_success ".env.production exists"

# Load environment
export $(grep -v '^#' .env.production | xargs)

echo ""

# ====================================================================
# Step 3: Install Certbot (if needed)
# ====================================================================

log_info "Step 3: Ensuring certbot is installed..."
echo ""

if ! command -v certbot &> /dev/null; then
    log_info "Installing certbot..."
    sudo apt-get update
    sudo apt-get install -y certbot python3-certbot-nginx
    log_success "Certbot installed"
else
    log_success "Certbot already installed"
fi

echo ""

# ====================================================================
# Step 4: Setup Native Nginx Configuration
# ====================================================================

log_info "Step 4: Configuring native nginx..."
echo ""

# Create certbot webroot
log_info "Creating certbot webroot..."
sudo mkdir -p /var/www/certbot-aitrademaestro
sudo chown -R www-data:www-data /var/www/certbot-aitrademaestro
log_success "Certbot webroot created"

# Check if snakeoil cert exists (for initial nginx config)
if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem ]; then
    log_info "Creating temporary self-signed certificate..."
    sudo apt-get install -y ssl-cert
fi

# Copy nginx config
log_info "Installing nginx configuration..."
sudo cp "$PROJECT_ROOT/nginx-native-config/aitrademaestro.conf" /etc/nginx/sites-available/aitrademaestro

# Enable site
log_info "Enabling site..."
sudo ln -sf /etc/nginx/sites-available/aitrademaestro /etc/nginx/sites-enabled/aitrademaestro

# Test nginx config
log_info "Testing nginx configuration..."
if ! sudo nginx -t; then
    log_error "Nginx configuration test failed!"
    exit 1
fi
log_success "Nginx configuration is valid"

# Start or reload nginx
log_info "Starting/reloading nginx..."
if sudo systemctl is-active --quiet nginx; then
    sudo systemctl reload nginx
    log_success "Nginx reloaded"
else
    sudo systemctl start nginx
    log_success "Nginx started"
fi

echo ""

# ====================================================================
# Step 5: Request SSL Certificate
# ====================================================================

log_info "Step 5: Setting up SSL certificate..."
echo ""

# Check if certificate already exists
if sudo test -d "/etc/letsencrypt/live/$DOMAIN"; then
    log_success "SSL certificate already exists for $DOMAIN"
else
    log_info "Requesting SSL certificate from Let's Encrypt..."
    log_info "Domain: $DOMAIN"
    log_info "Email: $EMAIL"
    echo ""

    # Request certificate
    if sudo certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --non-interactive --redirect; then
        log_success "SSL certificate obtained successfully!"
    else
        log_error "Failed to obtain SSL certificate"
        log_warning "Continuing anyway... you can fix SSL later"
    fi
fi

echo ""

# ====================================================================
# Step 6: Stop Old Containers
# ====================================================================

log_info "Step 6: Cleaning up old containers..."
echo ""

docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker-compose down 2>/dev/null || true
docker-compose -f docker-compose.dev.yml down 2>/dev/null || true

log_success "Old containers stopped"

echo ""

# ====================================================================
# Step 7: Build and Start Docker Containers
# ====================================================================

log_info "Step 7: Building and starting Docker containers..."
echo ""

log_info "Building images (this may take a few minutes)..."
docker-compose -f docker-compose.prod.yml build --no-cache

log_info "Starting services..."
docker-compose -f docker-compose.prod.yml up -d

log_info "Waiting for services to start..."
sleep 10

# Check container status
log_info "Container status:"
docker ps --filter "name=aitrademaestro" --format "table {{.Names}}\t{{.Status}}"

echo ""

# ====================================================================
# Step 8: Run Database Migrations
# ====================================================================

log_info "Step 8: Running database migrations..."
echo ""

if docker-compose -f docker-compose.prod.yml exec -T backend alembic upgrade head 2>/dev/null; then
    log_success "Database migrations completed"
else
    log_warning "Migrations failed or no migrations to run"
fi

echo ""

# ====================================================================
# Step 9: Verify Deployment
# ====================================================================

log_info "Step 9: Verifying deployment..."
echo ""

# Test Docker container locally
log_info "Testing Docker container (localhost:8080)..."
sleep 3
DOCKER_HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 || echo "000")

if [ "$DOCKER_HTTP" = "200" ]; then
    log_success "Docker container is responding (HTTP $DOCKER_HTTP)"
else
    log_warning "Docker container returned HTTP $DOCKER_HTTP"
    log_info "Checking logs..."
    docker logs aitrademaestro-nginx --tail 20 || true
fi

# Test public HTTPS
log_info "Testing public HTTPS (https://$DOMAIN)..."
PUBLIC_HTTPS=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN 2>/dev/null || echo "000")

if [ "$PUBLIC_HTTPS" = "200" ]; then
    log_success "Public HTTPS is working (HTTP $PUBLIC_HTTPS)"
else
    log_warning "Public HTTPS returned HTTP $PUBLIC_HTTPS"
fi

echo ""

# ====================================================================
# Final Report
# ====================================================================

echo "===================================================================="
echo "   Deployment Summary"
echo "===================================================================="
echo ""

# Check overall status
ALL_GOOD=true

# Check nginx
if sudo systemctl is-active --quiet nginx; then
    log_success "Native Nginx: Running"
else
    log_error "Native Nginx: Not running"
    ALL_GOOD=false
fi

# Check Docker containers
RUNNING_CONTAINERS=$(docker ps --filter "name=aitrademaestro" --filter "status=running" -q | wc -l)
if [ "$RUNNING_CONTAINERS" -ge 4 ]; then
    log_success "Docker Containers: $RUNNING_CONTAINERS running"
else
    log_warning "Docker Containers: Only $RUNNING_CONTAINERS running (expected 5+)"
    ALL_GOOD=false
fi

# Check SSL
if sudo test -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem"; then
    EXPIRY=$(sudo openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" | cut -d= -f2)
    log_success "SSL Certificate: Valid (expires: $EXPIRY)"
else
    log_warning "SSL Certificate: Not found"
    ALL_GOOD=false
fi

# Check connectivity
if [ "$PUBLIC_HTTPS" = "200" ]; then
    log_success "Public Access: HTTPS working"
elif [ "$DOCKER_HTTP" = "200" ]; then
    log_warning "Public Access: Docker works locally, check firewall/DNS"
    ALL_GOOD=false
else
    log_error "Public Access: Not working"
    ALL_GOOD=false
fi

echo ""

if [ "$ALL_GOOD" = true ]; then
    echo "===================================================================="
    echo -e "${GREEN}   🎉 DEPLOYMENT SUCCESSFUL!${NC}"
    echo "===================================================================="
    echo ""
    echo -e "${GREEN}Your application is live at:${NC}"
    echo -e "   ${BLUE}https://$DOMAIN${NC}"
    echo ""
    echo "✅ All services running"
    echo "✅ SSL certificate installed"
    echo "✅ Public HTTPS access working"
    echo ""
else
    echo "===================================================================="
    echo -e "${YELLOW}   ⚠️  DEPLOYMENT COMPLETED WITH WARNINGS${NC}"
    echo "===================================================================="
    echo ""
    echo "Your application is accessible at:"
    echo "   http://localhost:8080 (Docker)"
    echo "   https://$DOMAIN (if DNS/firewall configured)"
    echo ""
    echo "⚠️  Some components need attention (see warnings above)"
    echo ""
fi

echo "📊 Useful Commands:"
echo ""
echo "  Native Nginx:"
echo "    sudo systemctl status nginx"
echo "    sudo systemctl reload nginx"
echo "    sudo tail -f /var/log/nginx/aitrademaestro_error.log"
echo ""
echo "  Docker:"
echo "    docker ps"
echo "    docker logs aitrademaestro-nginx"
echo "    docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "  SSL Certificate:"
echo "    sudo certbot certificates"
echo "    sudo certbot renew --dry-run"
echo ""
echo "  Redeploy:"
echo "    ./scripts/prod/deploy.sh"
echo ""
echo "===================================================================="
echo ""
