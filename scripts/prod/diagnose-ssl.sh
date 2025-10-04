#!/bin/bash

set -e

DOMAIN="aitrademaestro.ddns.net"

echo "=========================================="
echo "SSL Diagnostics Tool"
echo "=========================================="
echo ""
echo "Domain: $DOMAIN"
echo ""

# 1. Check DNS
echo ">>> 1. Checking DNS Resolution..."
DNS_IP=$(dig +short $DOMAIN | head -1)
if [ -z "$DNS_IP" ]; then
    echo "❌ DNS not resolving for $DOMAIN"
    echo "   Please configure DNS A record to point to your server IP"
    exit 1
else
    echo "✓ DNS resolves to: $DNS_IP"
fi

# 2. Get server public IP
echo ""
echo ">>> 2. Checking Server Public IP..."
PUBLIC_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || echo "unknown")
echo "   Server public IP: $PUBLIC_IP"

if [ "$DNS_IP" != "$PUBLIC_IP" ]; then
    echo "⚠️  WARNING: DNS IP ($DNS_IP) != Server IP ($PUBLIC_IP)"
    echo "   DNS may not be pointing to this server!"
    echo "   Let's Encrypt validation will fail."
fi

# 3. Check port 80 locally
echo ""
echo ">>> 3. Checking Port 80 Locally..."
LOCAL_80=$(curl -s -o /dev/null -w "%{http_code}" http://localhost || echo "000")
if [ "$LOCAL_80" = "200" ]; then
    echo "✓ Port 80 accessible locally (HTTP $LOCAL_80)"
else
    echo "❌ Port 80 not accessible locally (HTTP $LOCAL_80)"
    exit 1
fi

# 4. Check port 80 publicly
echo ""
echo ">>> 4. Checking Port 80 Publicly..."
PUBLIC_80=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN 2>/dev/null || echo "000")
if [ "$PUBLIC_80" = "200" ]; then
    echo "✓ Port 80 accessible publicly (HTTP $PUBLIC_80)"
else
    echo "❌ Port 80 NOT accessible publicly (HTTP $PUBLIC_80)"
    echo "   Let's Encrypt CANNOT validate your domain!"
    echo ""
    echo "Possible issues:"
    echo "  1. Firewall blocking port 80"
    echo "  2. Port forwarding not configured (if behind NAT)"
    echo "  3. ISP blocking port 80"
    echo "  4. DNS not propagated yet"
fi

# 5. Check ACME challenge path
echo ""
echo ">>> 5. Testing ACME Challenge Path..."
ACME_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN/.well-known/acme-challenge/test 2>/dev/null || echo "000")
if [ "$ACME_TEST" = "404" ] || [ "$ACME_TEST" = "200" ]; then
    echo "✓ ACME path accessible (HTTP $ACME_TEST)"
else
    echo "⚠️  ACME path returned HTTP $ACME_TEST"
fi

# 6. Check nginx logs
echo ""
echo ">>> 6. Recent Nginx Logs..."
docker logs aitrademaestro-nginx --tail 10 2>&1 | head -10 || echo "Cannot read nginx logs"

# 7. Check certbot logs
echo ""
echo ">>> 7. Recent Certbot Logs..."
if [ -f nginx/certbot/conf/letsencrypt.log ]; then
    echo "Last certbot log entries:"
    tail -20 nginx/certbot/conf/letsencrypt.log
else
    echo "No certbot logs found yet"
fi

# 8. Check existing certificates
echo ""
echo ">>> 8. Checking Existing Certificates..."
docker-compose -f docker-compose.prod.yml run --rm certbot certificates 2>&1 | grep -A 10 "Certificate Name\|No certificates found" || echo "Cannot check certificates"

# 9. Summary
echo ""
echo "=========================================="
echo "Diagnostic Summary"
echo "=========================================="
echo ""

if [ "$DNS_IP" = "$PUBLIC_IP" ] && [ "$PUBLIC_80" = "200" ]; then
    echo "✅ Everything looks good!"
    echo "   SSL certificate should work."
    echo ""
    echo "Next step:"
    echo "  ./scripts/prod/enable-ssl.sh"
else
    echo "❌ Issues detected!"
    echo ""
    echo "Required fixes:"

    if [ "$DNS_IP" != "$PUBLIC_IP" ]; then
        echo "  1. Fix DNS: Point $DOMAIN to $PUBLIC_IP"
        echo "     Current DNS points to: $DNS_IP"
    fi

    if [ "$PUBLIC_80" != "200" ]; then
        echo "  2. Make port 80 publicly accessible"
        echo "     Check firewall: sudo ufw allow 80/tcp"
        echo "     Check router port forwarding (if behind NAT)"
    fi

    echo ""
    echo "Test after fixing:"
    echo "  curl http://$DOMAIN"
fi

echo ""
