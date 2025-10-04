#!/bin/bash

# ====================================================================
# AI TradeMaestro - Complete HTTPS Deployment Script (Robust Edition)
# ====================================================================
# Handles all errors from scratch to production with HTTPS
# Includes comprehensive error handling and recovery mechanisms
# ====================================================================

# Disable exit on error - we'll handle errors manually
set +e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

DOMAIN="${DOMAIN:-aitrademaestro.ddns.net}"
EMAIL="${SSL_EMAIL:-deepalgotrader@gmail.com}"

# Error tracking
ERRORS=0
WARNINGS=0

# ====================================================================
# Helper Functions
# ====================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    ((ERRORS++))
}

log_step() {
    echo -e "${MAGENTA}[STEP]${NC} $1"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        return 1
    fi
    return 0
}

safe_exec() {
    local cmd="$1"
    local error_msg="$2"
    local can_continue="${3:-false}"

    if eval "$cmd" &> /dev/null; then
        return 0
    else
        if [ "$can_continue" = "true" ]; then
            log_warning "$error_msg (continuing anyway)"
            return 1
        else
            log_error "$error_msg"
            return 1
        fi
    fi
}

# ====================================================================
# Main Script
# ====================================================================

clear
echo ""
echo "===================================================================="
echo "   AI TradeMaestro - HTTPS Deployment (Robust Edition)"
echo "===================================================================="
echo ""
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# ====================================================================
# Step 1: Environment Check
# ====================================================================

log_step "Step 1: Checking environment..."
echo ""

# Check if on VPS
if [ ! -f /etc/nginx/nginx.conf ]; then
    log_error "Native nginx not found. Are you on the VPS?"
    echo ""
    log_info "This script must be run on a VPS with nginx installed."
    exit 1
fi
log_success "Native nginx detected"

# Check required commands
if check_command docker; then
    log_success "docker is installed"
else
    log_error "docker is not installed"
    log_info "Install with: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

if check_command docker-compose; then
    log_success "docker-compose is installed"
else
    log_error "docker-compose is not installed"
    log_info "Install with: sudo apt-get install -y docker-compose-plugin"
    exit 1
fi

if check_command certbot; then
    log_success "certbot is installed"
    INSTALL_CERTBOT=false
else
    log_warning "certbot not found, will install"
    INSTALL_CERTBOT=true
fi

if check_command curl; then
    log_success "curl is installed"
else
    log_error "curl is not installed"
    log_info "Install with: sudo apt-get install -y curl"
    exit 1
fi

echo ""

# ====================================================================
# Step 2: Project Directory Check
# ====================================================================

log_step "Step 2: Checking project directory..."
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

if ! cd "$PROJECT_ROOT"; then
    log_error "Cannot access project directory: $PROJECT_ROOT"
    exit 1
fi

log_success "Working directory: $PROJECT_ROOT"

# Check .env.production
if [ ! -f .env.production ]; then
    log_error ".env.production not found!"

    if [ -f .env.production.example ]; then
        log_info "Creating from template..."
        cp .env.production.example .env.production
        log_warning "Please edit .env.production with your credentials!"
        log_warning "Then run this script again."
        exit 1
    else
        log_error ".env.production.example also not found!"
        exit 1
    fi
fi

log_success ".env.production exists"

# Load environment with error handling
if ! set -a; source .env.production 2>/dev/null; set +a; then
    log_warning "Could not load .env.production (may have syntax errors)"
fi

# Check critical environment variables
if [ -z "$POSTGRES_PASSWORD" ]; then
    log_warning "POSTGRES_PASSWORD not set in .env.production"
fi

if [ -z "$REDIS_PASSWORD" ]; then
    log_warning "REDIS_PASSWORD not set in .env.production"
fi

if [ -z "$SECRET_KEY" ]; then
    log_warning "SECRET_KEY not set in .env.production"
fi

echo ""

# ====================================================================
# Step 3: Stop Conflicting Services
# ====================================================================

log_step "Step 3: Stopping conflicting services..."
echo ""

# Stop Docker containers with retries
log_info "Stopping Docker containers..."
MAX_RETRIES=3
RETRY=0

while [ $RETRY -lt $MAX_RETRIES ]; do
    if docker-compose -f docker-compose.prod.yml down 2>/dev/null; then
        log_success "Docker containers stopped"
        break
    fi
    ((RETRY++))
    if [ $RETRY -lt $MAX_RETRIES ]; then
        log_warning "Retry $RETRY/$MAX_RETRIES..."
        sleep 2
    else
        log_warning "Could not stop docker-compose (may not be running)"
    fi
done

# Also try legacy docker-compose
docker-compose down 2>/dev/null || true

# Kill any orphaned Docker nginx processes
log_info "Checking for orphaned nginx processes..."
DOCKER_NGINX=$(docker ps -q --filter "name=nginx" --filter "name=aitrademaestro" 2>/dev/null)
if [ ! -z "$DOCKER_NGINX" ]; then
    log_info "Stopping orphaned nginx containers..."
    if docker stop $DOCKER_NGINX 2>/dev/null; then
        log_success "Orphaned containers stopped"
    else
        log_warning "Could not stop some containers"
    fi
else
    log_success "No orphaned containers found"
fi

# Handle native nginx
if sudo systemctl is-active --quiet nginx 2>/dev/null; then
    log_info "Stopping native nginx temporarily..."
    if sudo systemctl stop nginx 2>/dev/null; then
        log_success "Native nginx stopped"
    else
        log_error "Could not stop native nginx"
        log_info "Trying to kill nginx processes..."
        sudo pkill nginx 2>/dev/null || true
        sleep 2
    fi
else
    log_success "Native nginx not running"
fi

echo ""

# ====================================================================
# Step 4: Install Certbot (if needed)
# ====================================================================

if [ "$INSTALL_CERTBOT" = true ]; then
    log_step "Step 4: Installing certbot..."
    echo ""

    log_info "Updating package list..."
    if ! sudo apt-get update 2>/dev/null; then
        log_warning "apt-get update failed, continuing anyway"
    fi

    log_info "Installing certbot and nginx plugin..."
    if sudo apt-get install -y certbot python3-certbot-nginx 2>/dev/null; then
        log_success "Certbot installed"
    else
        log_error "Failed to install certbot"
        log_warning "SSL setup may fail - continuing anyway"
    fi
    echo ""
else
    log_step "Step 4: Certbot already installed"
    echo ""
fi

# ====================================================================
# Step 5: Setup Native Nginx Configuration
# ====================================================================

log_step "Step 5: Configuring native nginx..."
echo ""

# Create certbot webroot
log_info "Creating certbot webroot..."
if sudo mkdir -p /var/www/certbot-aitrademaestro 2>/dev/null; then
    sudo chown -R www-data:www-data /var/www/certbot-aitrademaestro 2>/dev/null || log_warning "Could not set ownership"
    log_success "Certbot webroot created"
else
    log_warning "Could not create certbot webroot (may already exist)"
fi

# Install ssl-cert package for snakeoil certificate (fallback)
if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem ]; then
    log_info "Installing temporary self-signed certificate..."
    if sudo apt-get install -y ssl-cert 2>/dev/null; then
        log_success "Self-signed certificate installed"
    else
        log_warning "Could not install ssl-cert package"
    fi
fi

# Check if nginx config exists
if [ ! -f "$PROJECT_ROOT/nginx-native-config/aitrademaestro.conf" ]; then
    log_error "nginx configuration file not found at: $PROJECT_ROOT/nginx-native-config/aitrademaestro.conf"
    exit 1
fi

# Copy nginx config
log_info "Installing nginx configuration..."
if sudo cp "$PROJECT_ROOT/nginx-native-config/aitrademaestro.conf" /etc/nginx/sites-available/aitrademaestro 2>/dev/null; then
    log_success "Nginx configuration copied"
else
    log_error "Failed to copy nginx configuration"
    exit 1
fi

# Enable site
log_info "Enabling site..."
if sudo ln -sf /etc/nginx/sites-available/aitrademaestro /etc/nginx/sites-enabled/aitrademaestro 2>/dev/null; then
    log_success "Site enabled"
else
    log_warning "Could not enable site (may already be enabled)"
fi

# Remove default site if it conflicts (optional)
if [ -f /etc/nginx/sites-enabled/default ]; then
    log_info "Checking for default site conflicts..."
    # Only remove if it's listening on 80/443 for our domain
    if grep -q "listen.*80" /etc/nginx/sites-enabled/default 2>/dev/null; then
        log_info "Disabling default nginx site to prevent conflicts..."
        sudo rm /etc/nginx/sites-enabled/default 2>/dev/null || log_warning "Could not remove default site"
    fi
fi

# Test nginx config
log_info "Testing nginx configuration..."
NGINX_TEST_OUTPUT=$(sudo nginx -t 2>&1)
if [ $? -eq 0 ]; then
    log_success "Nginx configuration is valid"
else
    log_error "Nginx configuration test failed!"
    echo "$NGINX_TEST_OUTPUT"
    log_info "Attempting to diagnose issue..."

    # Check for common issues
    if echo "$NGINX_TEST_OUTPUT" | grep -q "ssl_certificate"; then
        log_warning "SSL certificate issue detected - may need to use fallback cert"
    fi

    exit 1
fi

# Start nginx
log_info "Starting native nginx..."
if sudo systemctl start nginx 2>/dev/null; then
    sleep 2
    if sudo systemctl is-active --quiet nginx; then
        log_success "Nginx started successfully"
    else
        log_error "Nginx failed to start"
        log_info "Checking logs..."
        sudo journalctl -xeu nginx.service --no-pager -n 20 2>/dev/null || true
        exit 1
    fi
else
    log_error "Failed to start nginx"
    exit 1
fi

echo ""

# ====================================================================
# Step 6: Request SSL Certificate
# ====================================================================

log_step "Step 6: Setting up SSL certificate..."
echo ""

SSL_EXISTS=false
SSL_VALID=false

# Check if certificate already exists
if sudo test -d "/etc/letsencrypt/live/$DOMAIN" 2>/dev/null; then
    log_success "SSL certificate directory exists for $DOMAIN"
    SSL_EXISTS=true

    # Check if certificate files exist and are readable
    if sudo test -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" && \
       sudo test -f "/etc/letsencrypt/live/$DOMAIN/privkey.pem"; then

        # Check expiry
        EXPIRY=$(sudo openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" 2>/dev/null | cut -d= -f2 || echo "unknown")

        if [ "$EXPIRY" != "unknown" ]; then
            log_success "SSL certificate valid (expires: $EXPIRY)"
            SSL_VALID=true

            # Check if expiring soon (30 days)
            if ! sudo openssl x509 -checkend 2592000 -noout -in "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" 2>/dev/null; then
                log_warning "Certificate expires in less than 30 days, will attempt renewal"
                log_info "Renewing SSL certificate..."
                if sudo certbot renew --nginx --non-interactive 2>/dev/null; then
                    log_success "Certificate renewed successfully"
                else
                    log_warning "Certificate renewal failed (will continue with existing cert)"
                fi
            fi
        else
            log_warning "Could not read certificate expiry"
        fi
    else
        log_warning "Certificate files not found or not readable"
    fi
else
    log_info "No existing SSL certificate found for $DOMAIN"
fi

# Request new certificate if needed
if [ "$SSL_VALID" = false ]; then
    log_info "Requesting new SSL certificate from Let's Encrypt..."
    log_info "Domain: $DOMAIN"
    log_info "Email: $EMAIL"
    echo ""

    # Try to request certificate
    CERTBOT_OUTPUT=$(sudo certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --non-interactive --redirect 2>&1)
    CERTBOT_EXIT=$?

    if [ $CERTBOT_EXIT -eq 0 ]; then
        log_success "SSL certificate obtained successfully!"
        SSL_VALID=true
    else
        log_error "Failed to obtain SSL certificate"
        log_warning "Certificate request output:"
        echo "$CERTBOT_OUTPUT" | tail -10
        echo ""
        log_warning "Possible causes:"
        log_warning "  1. DNS not pointing to this server (dig $DOMAIN)"
        log_warning "  2. Firewall blocking ports 80/443 (ufw status)"
        log_warning "  3. Domain not accessible from internet"
        log_warning "  4. Rate limiting from Let's Encrypt"
        echo ""
        log_warning "Continuing with self-signed certificate..."

        # Update nginx config to use self-signed cert as fallback
        log_info "Configuring fallback to self-signed certificate..."
        if [ -f /etc/ssl/certs/ssl-cert-snakeoil.pem ]; then
            # Config already has fallback to snakeoil cert
            log_success "Fallback certificate available"
        else
            log_error "No fallback certificate available"
        fi
    fi
fi

# Fix nginx config to use correct SSL certificate
if [ "$SSL_VALID" = true ]; then
    log_info "Updating nginx to use Let's Encrypt certificate..."

    # Check if nginx config is still using snakeoil cert
    if sudo grep -q "ssl-cert-snakeoil" /etc/nginx/sites-enabled/aitrademaestro 2>/dev/null; then
        log_info "Fixing nginx SSL certificate configuration..."

        # Create temporary config with correct cert paths
        sudo sed -i "s|ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;|ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;|g" /etc/nginx/sites-enabled/aitrademaestro 2>/dev/null
        sudo sed -i "s|ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;|ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;|g" /etc/nginx/sites-enabled/aitrademaestro 2>/dev/null

        # Test nginx config
        if sudo nginx -t 2>/dev/null; then
            log_success "SSL configuration updated"

            # Reload nginx
            if sudo systemctl reload nginx 2>/dev/null; then
                log_success "Nginx reloaded with new SSL configuration"
            else
                log_warning "Could not reload nginx (will restart later)"
            fi
        else
            log_warning "Nginx config test failed after SSL update, reverting..."
            # Revert by copying original config again
            sudo cp "$PROJECT_ROOT/nginx-native-config/aitrademaestro.conf" /etc/nginx/sites-enabled/aitrademaestro 2>/dev/null
        fi
    else
        log_success "Nginx already using correct SSL certificate"
    fi
fi

echo ""

# ====================================================================
# Step 7: Build and Start Docker Containers
# ====================================================================

log_step "Step 7: Building and starting Docker containers..."
echo ""

log_info "Building images (this may take a few minutes)..."

BUILD_OUTPUT=$(docker-compose -f docker-compose.prod.yml build --no-cache 2>&1)
BUILD_EXIT=$?

if [ $BUILD_EXIT -eq 0 ]; then
    log_success "Docker images built successfully"
else
    log_error "Docker build failed"
    echo "$BUILD_OUTPUT" | tail -20
    log_warning "Trying to continue with existing images..."
fi

log_info "Starting services..."

START_OUTPUT=$(docker-compose -f docker-compose.prod.yml up -d 2>&1)
START_EXIT=$?

if [ $START_EXIT -eq 0 ]; then
    log_success "Docker services started"
else
    log_error "Failed to start Docker services"
    echo "$START_OUTPUT" | tail -20
    log_info "Attempting to diagnose issue..."
    docker ps -a --filter "name=aitrademaestro" 2>/dev/null || true
fi

log_info "Waiting for services to start..."
sleep 10

# Check container status
log_info "Container status:"
RUNNING_CONTAINERS=$(docker ps --filter "name=aitrademaestro" --filter "status=running" -q 2>/dev/null | wc -l)
docker ps --filter "name=aitrademaestro" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || log_warning "Could not list containers"

if [ "$RUNNING_CONTAINERS" -lt 4 ]; then
    log_warning "Only $RUNNING_CONTAINERS containers running (expected 5+)"
    log_info "Checking failed containers..."
    docker ps -a --filter "name=aitrademaestro" --filter "status=exited" 2>/dev/null || true
fi

echo ""

# ====================================================================
# Step 8: Run Database Migrations
# ====================================================================

log_step "Step 8: Running database migrations..."
echo ""

# Wait for database
log_info "Waiting for database to be ready..."
sleep 5

# Check if backend container is running
if docker ps --filter "name=aitrademaestro-backend" --filter "status=running" -q | grep -q .; then
    # Check if alembic exists in container
    if docker-compose -f docker-compose.prod.yml exec -T backend which alembic &>/dev/null; then
        log_info "Running migrations..."

        MIGRATION_OUTPUT=$(docker-compose -f docker-compose.prod.yml exec -T backend alembic upgrade head 2>&1)
        MIGRATION_EXIT=$?

        if [ $MIGRATION_EXIT -eq 0 ]; then
            log_success "Database migrations completed"
        else
            log_warning "Migrations failed or no migrations to run"
            echo "$MIGRATION_OUTPUT" | tail -10
        fi
    else
        log_warning "Alembic not found in backend container, skipping migrations"
    fi
else
    log_warning "Backend container not running, skipping migrations"
fi

echo ""

# ====================================================================
# Step 9: Verify Deployment
# ====================================================================

log_step "Step 9: Verifying deployment..."
echo ""

# Test Docker container locally
log_info "Testing Docker container (localhost:8080)..."
sleep 3

DOCKER_HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")

if [ "$DOCKER_HTTP" = "200" ] || [ "$DOCKER_HTTP" = "301" ] || [ "$DOCKER_HTTP" = "302" ]; then
    log_success "Docker container is responding (HTTP $DOCKER_HTTP)"
    DOCKER_OK=true
else
    log_warning "Docker container returned HTTP $DOCKER_HTTP"
    log_info "Checking nginx logs..."
    docker logs aitrademaestro-nginx --tail 20 2>&1 | tail -10 || true
    DOCKER_OK=false
fi

# Test public HTTP
log_info "Testing public HTTP (http://$DOMAIN)..."
PUBLIC_HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN 2>/dev/null || echo "000")

if [ "$PUBLIC_HTTP" = "200" ] || [ "$PUBLIC_HTTP" = "301" ] || [ "$PUBLIC_HTTP" = "302" ]; then
    log_success "Public HTTP is working (HTTP $PUBLIC_HTTP)"
    HTTP_OK=true
else
    log_warning "Public HTTP returned HTTP $PUBLIC_HTTP"
    HTTP_OK=false
fi

# Test public HTTPS
log_info "Testing public HTTPS (https://$DOMAIN)..."
PUBLIC_HTTPS=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN 2>/dev/null || echo "000")

if [ "$PUBLIC_HTTPS" = "200" ]; then
    log_success "Public HTTPS is working (HTTP $PUBLIC_HTTPS)"
    HTTPS_OK=true
elif [ "$PUBLIC_HTTPS" = "000" ]; then
    log_warning "Public HTTPS returned HTTP $PUBLIC_HTTPS (connection failed)"
    log_info "This could be due to self-signed certificate or firewall issues"
    HTTPS_OK=false
else
    log_warning "Public HTTPS returned HTTP $PUBLIC_HTTPS"
    HTTPS_OK=false
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

# Check native nginx
if sudo systemctl is-active --quiet nginx 2>/dev/null; then
    log_success "Native Nginx: Running"
else
    log_error "Native Nginx: Not running"
    ALL_GOOD=false
fi

# Check Docker containers
if [ "$RUNNING_CONTAINERS" -ge 4 ]; then
    log_success "Docker Containers: $RUNNING_CONTAINERS running"
else
    log_warning "Docker Containers: Only $RUNNING_CONTAINERS running (expected 5+)"
    ALL_GOOD=false
fi

# Check SSL
if [ "$SSL_VALID" = true ]; then
    EXPIRY=$(sudo openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" 2>/dev/null | cut -d= -f2 || echo "unknown")
    log_success "SSL Certificate: Valid (expires: $EXPIRY)"
else
    log_warning "SSL Certificate: Using self-signed (Let's Encrypt failed)"
    ALL_GOOD=false
fi

# Check connectivity
if [ "$HTTPS_OK" = true ]; then
    log_success "Public Access: HTTPS working"
elif [ "$HTTP_OK" = true ]; then
    log_warning "Public Access: HTTP works, HTTPS needs attention"
    ALL_GOOD=false
elif [ "$DOCKER_OK" = true ]; then
    log_warning "Public Access: Docker works locally, check firewall/DNS"
    ALL_GOOD=false
else
    log_error "Public Access: Not working"
    ALL_GOOD=false
fi

echo ""
echo "Statistics:"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [ "$ALL_GOOD" = true ] && [ "$ERRORS" -eq 0 ]; then
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
    echo "Your application status:"

    if [ "$DOCKER_OK" = true ]; then
        echo -e "   ${GREEN}✓${NC} Docker: http://localhost:8080"
    else
        echo -e "   ${RED}✗${NC} Docker: Not responding"
    fi

    if [ "$HTTP_OK" = true ]; then
        echo -e "   ${GREEN}✓${NC} HTTP: http://$DOMAIN"
    else
        echo -e "   ${RED}✗${NC} HTTP: Not accessible"
    fi

    if [ "$HTTPS_OK" = true ]; then
        echo -e "   ${GREEN}✓${NC} HTTPS: https://$DOMAIN"
    else
        echo -e "   ${YELLOW}⚠${NC} HTTPS: Needs attention"
    fi

    echo ""

    if [ "$ERRORS" -gt 0 ]; then
        echo -e "${RED}⚠️  $ERRORS error(s) occurred during deployment${NC}"
    fi

    if [ "$WARNINGS" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS warning(s) - review output above${NC}"
    fi
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
echo "  Troubleshooting:"
echo "    # Check what's using port 80/443:"
echo "    sudo ss -tulpn | grep ':80'"
echo "    sudo ss -tulpn | grep ':443'"
echo ""
echo "    # Check native nginx config:"
echo "    sudo nginx -t"
echo "    sudo cat /etc/nginx/sites-enabled/aitrademaestro"
echo ""
echo "    # Restart everything:"
echo "    sudo systemctl restart nginx"
echo "    docker-compose -f docker-compose.prod.yml restart"
echo ""
echo "    # Fix SSL certificate configuration:"
echo "    ./scripts/prod/fix-ssl.sh"
echo ""
echo "===================================================================="
echo ""

# Exit with appropriate code
if [ "$ERRORS" -gt 0 ]; then
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    exit 0
else
    exit 0
fi
