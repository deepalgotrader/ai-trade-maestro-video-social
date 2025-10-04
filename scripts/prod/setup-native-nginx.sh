#!/bin/bash

# Setup Native Nginx Reverse Proxy for AI TradeMaestro
# This script configures the VPS native nginx to proxy requests to Docker

set -e

DOMAIN="aitrademaestro.ddns.net"
EMAIL="deepalgotrader@gmail.com"

echo "=========================================="
echo "Native Nginx Setup for AI TradeMaestro"
echo "=========================================="
echo ""

# Check if running on VPS
if [ ! -f /etc/nginx/nginx.conf ]; then
    echo "❌ Native nginx not found. This script is for VPS only."
    echo "   Run this on your VPS, not locally."
    exit 1
fi

echo ">>> Creating certbot webroot directory..."
sudo mkdir -p /var/www/certbot-aitrademaestro
sudo chown -R www-data:www-data /var/www/certbot-aitrademaestro

echo ""
echo ">>> Copying nginx configuration..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

sudo cp "$PROJECT_ROOT/nginx-native-config/aitrademaestro.conf" /etc/nginx/sites-available/aitrademaestro

echo ""
echo ">>> Enabling site..."
sudo ln -sf /etc/nginx/sites-available/aitrademaestro /etc/nginx/sites-enabled/aitrademaestro

echo ""
echo ">>> Testing nginx configuration..."
sudo nginx -t

if [ $? -ne 0 ]; then
    echo "❌ Nginx configuration test failed!"
    exit 1
fi

echo ""
echo ">>> Reloading nginx..."
sudo systemctl reload nginx

echo ""
echo ">>> Testing HTTP access..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
echo "HTTP Status: $HTTP_CODE"

echo ""
echo ">>> Requesting SSL certificate from Let's Encrypt..."
echo "   Domain: $DOMAIN"
echo "   Email: $EMAIL"
echo ""

sudo certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --non-interactive

CERT_EXIT=$?

if [ $CERT_EXIT -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ Native Nginx Setup Complete!"
    echo "=========================================="
    echo ""
    echo "🔒 Your application is now accessible at:"
    echo "   https://$DOMAIN"
    echo ""
    echo "Configuration:"
    echo "  • Native Nginx: Handles SSL on ports 80/443"
    echo "  • Reverse Proxy: → localhost:8080 (Docker)"
    echo "  • SSL Certificate: Auto-managed by certbot"
    echo ""
    echo "Next steps:"
    echo "  1. Deploy Docker app: ./scripts/prod/deploy.sh"
    echo "  2. Test: curl https://$DOMAIN"
    echo ""
else
    echo ""
    echo "⚠️  SSL certificate request failed"
    echo ""
    echo "Your site is accessible at:"
    echo "   http://$DOMAIN (redirects to https, but will fail)"
    echo ""
    echo "Manual SSL setup:"
    echo "   sudo certbot --nginx -d $DOMAIN"
    echo ""
fi

echo "Useful commands:"
echo "  • Reload nginx: sudo systemctl reload nginx"
echo "  • Check status: sudo systemctl status nginx"
echo "  • View logs: sudo tail -f /var/log/nginx/aitrademaestro_error.log"
echo "  • Renew SSL: sudo certbot renew"
echo ""
