#!/bin/bash

# Deploy with CORRECT Traefik entrypoint names

SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"

echo "🚀 Deploying bimaided.com with correct Traefik configuration..."
echo ""

sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << 'ENDSSH'
    echo "1️⃣ Stopping old container..."
    docker stop woswgwcockowgs8k0ocgcwg4-bimaided 2>/dev/null || true
    docker rm woswgwcockowgs8k0ocgcwg4-bimaided 2>/dev/null || true
    
    echo ""
    echo "2️⃣ Starting with CORRECT Traefik labels..."
    
    docker run -d \
        --name woswgwcockowgs8k0ocgcwg4-bimaided \
        --network coolify \
        --restart unless-stopped \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.bimaided-https.rule=Host(\`bimaided.com\`) || Host(\`www.bimaided.com\`)" \
        --label "traefik.http.routers.bimaided-https.entrypoints=https" \
        --label "traefik.http.routers.bimaided-https.tls=true" \
        --label "traefik.http.routers.bimaided-https.tls.certresolver=letsencrypt" \
        --label "traefik.http.routers.bimaided-http.rule=Host(\`bimaided.com\`) || Host(\`www.bimaided.com\`)" \
        --label "traefik.http.routers.bimaided-http.entrypoints=http" \
        --label "traefik.http.routers.bimaided-http.middlewares=redirect-to-https@file" \
        --label "traefik.http.services.bimaided.loadbalancer.server.port=3000" \
        -e NODE_ENV=production \
        -e NEXT_PUBLIC_SUPABASE_URL="http://supabasekong-n4g4og0cos0ocwg0ss8cswss.72.60.222.97.sslip.io" \
        -e NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoiYW5vbiJ9.TuGXG83THiqENV8Nern5GwkiS7R6OCY4SGcB9cD-6XE" \
        -e SUPABASE_SERVICE_KEY="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoic2VydmljZV9yb2xlIn0.-X1sUGnaBrVLPeh3ZTgJN5SqEb55aI_mauvyKUyE4P8" \
        -e EMAIL_USER="bimaided.website@gmail.com" \
        -e EMAIL_PASSWORD="rwgy biho ilda memw" \
        -e EMAIL_TO="tasneemlabeeb@gmail.com" \
        -e NEXT_PUBLIC_RECAPTCHA_SITE_KEY="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI" \
        tasneemlabeeb/bimsync-portal:latest
    
    echo ""
    echo "3️⃣ Container started!"
    docker ps | grep bimaided
    
    echo ""
    echo "4️⃣ Waiting for Traefik to pick up configuration..."
    sleep 5
    
    echo ""
    echo "5️⃣ Checking Traefik logs for bimaided..."
    docker logs coolify-proxy --tail 20 2>&1 | grep -i "bimaided\|error" | tail -10
    
    echo ""
    echo "6️⃣ Testing if container is responding..."
    wget -q -O- --timeout=5 http://localhost:80 -H "Host: bimaided.com" | head -c 200 || echo "Not yet accessible via proxy"
ENDSSH

echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Try accessing now:"
echo "   http://bimaided.com"
echo "   https://bimaided.com"
echo ""
echo "⏳ SSL certificate generation may take 1-2 minutes"
echo "   (First time only)"
echo ""
