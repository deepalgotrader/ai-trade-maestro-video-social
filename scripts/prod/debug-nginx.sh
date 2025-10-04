#!/bin/bash

echo "=========================================="
echo "Nginx Debugging"
echo "=========================================="
echo ""

# 1. Check if nginx is running
echo ">>> 1. Checking nginx status..."
if docker ps | grep -q aitrademaestro-nginx; then
    echo "✓ Nginx container is running"
else
    echo "❌ Nginx container is NOT running"
    exit 1
fi

# 2. Check nginx logs
echo ""
echo ">>> 2. Recent nginx logs..."
docker logs aitrademaestro-nginx --tail 20

# 3. Check volume mounts
echo ""
echo ">>> 3. Checking volume mounts..."
docker inspect aitrademaestro-nginx | grep -A 20 '"Mounts"'

# 4. Check if directories exist in container
echo ""
echo ">>> 4. Checking directories in container..."
echo "Certbot webroot:"
docker exec aitrademaestro-nginx ls -la /var/www/certbot/ 2>/dev/null || echo "Directory not found"

echo ""
echo "ACME challenge path:"
docker exec aitrademaestro-nginx ls -la /var/www/certbot/.well-known/ 2>/dev/null || echo "Directory not found"

# 5. Check nginx configuration
echo ""
echo ">>> 5. Active nginx configuration..."
docker exec aitrademaestro-nginx cat /etc/nginx/conf.d/app.conf | head -30

# 6. Test nginx config validity
echo ""
echo ">>> 6. Testing nginx config..."
docker exec aitrademaestro-nginx nginx -t

# 7. Try to create test file
echo ""
echo ">>> 7. Testing write permissions..."
docker exec aitrademaestro-nginx sh -c 'mkdir -p /var/www/certbot/.well-known/acme-challenge && echo "test123" > /var/www/certbot/.well-known/acme-challenge/test-file' 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Write successful"

    # Test reading it back
    echo ""
    echo ">>> 8. Testing file access..."
    docker exec aitrademaestro-nginx cat /var/www/certbot/.well-known/acme-challenge/test-file 2>/dev/null || echo "Cannot read file"

    # Test HTTP access
    echo ""
    echo ">>> 9. Testing HTTP access..."
    curl -v http://localhost/.well-known/acme-challenge/test-file 2>&1 | grep -E "HTTP|test123|404|403"
else
    echo "❌ Write failed (read-only?)"
fi

# 8. Check what config file nginx is actually using
echo ""
echo ">>> 10. Checking which config files exist..."
docker exec aitrademaestro-nginx ls -la /etc/nginx/conf.d/

echo ""
echo "=========================================="
echo "Debug complete"
echo "=========================================="
echo ""
