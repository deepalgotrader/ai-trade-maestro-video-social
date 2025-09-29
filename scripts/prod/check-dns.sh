#!/bin/bash

DOMAIN="aitrademaestro.ddns.net"

echo "=========================================="
echo "DNS & Network Diagnostics"
echo "=========================================="
echo ""

echo ">>> Checking DNS resolution..."
DNS_IP=$(dig +short $DOMAIN 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)

if [ -z "$DNS_IP" ]; then
    echo "❌ DNS resolution failed for $DOMAIN"
    exit 1
fi

echo "✓ Domain resolves to: $DNS_IP"

echo ""
echo ">>> Checking server's public IP..."
SERVER_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || curl -s --max-time 5 icanhazip.com 2>/dev/null)

if [ -z "$SERVER_IP" ]; then
    echo "⚠️  Could not determine server's public IP"
else
    echo "✓ Server public IP: $SERVER_IP"

    echo ""
    if [ "$DNS_IP" = "$SERVER_IP" ]; then
        echo "✓ DNS is correctly pointing to this server!"
    else
        echo "❌ DNS MISMATCH!"
        echo "   Domain points to: $DNS_IP"
        echo "   This server IP:   $SERVER_IP"
        echo ""
        echo "Action: Update your DDNS to point to $SERVER_IP"
    fi
fi

echo ""
echo "=========================================="
echo "All checks completed!"
echo "=========================================="