#!/bin/bash

# Debug Coolify deployment

SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"

echo "🔍 Debugging bimaided.com deployment..."
echo ""

sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << 'ENDSSH'
    echo "1️⃣ Checking running containers:"
    echo "================================"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"
    
    echo ""
    echo "2️⃣ Checking Nginx/Caddy/Traefik (Coolify proxy):"
    echo "================================================"
    docker ps | grep -E "proxy|nginx|caddy|traefik" || echo "No proxy found"
    
    echo ""
    echo "3️⃣ Checking what's listening on port 80/443:"
    echo "============================================="
    netstat -tlnp | grep -E ":80|:443" || ss -tlnp | grep -E ":80|:443"
    
    echo ""
    echo "4️⃣ Testing direct connection to container:"
    echo "==========================================="
    curl -s http://localhost:3000 | head -n 20 || echo "Port 3000 not responding"
    
    echo ""
    echo "5️⃣ Checking Coolify logs for your app:"
    echo "======================================="
    docker ps --filter "name=bimsync" --filter "name=bimaided" --format "{{.Names}}"
    
    echo ""
    echo "6️⃣ Checking if domain is configured in proxy:"
    echo "=============================================="
    if [ -d "/var/lib/docker/volumes" ]; then
        find /var/lib/docker/volumes -name "*caddy*" -o -name "*traefik*" 2>/dev/null | head -5
    fi
ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "What we're looking for:"
echo "- Your container running on port 3000"
echo "- Coolify's proxy (Caddy/Traefik) running on 80/443"
echo "- Proxy configured to route bimaided.com to your container"
echo ""
