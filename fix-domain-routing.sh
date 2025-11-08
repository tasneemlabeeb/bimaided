#!/bin/bash

# Fix domain routing by adding proper Traefik labels

SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"

echo "🔧 Fixing bimaided.com routing in Traefik..."
echo ""

sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << 'ENDSSH'
    echo "1️⃣ Stopping current container..."
    CONTAINER_ID=$(docker ps -q --filter "name=woswgwcockowgs8k0ocgcwg4")
    if [ ! -z "$CONTAINER_ID" ]; then
        docker stop $CONTAINER_ID
        docker rm $CONTAINER_ID
    fi
    
    echo ""
    echo "2️⃣ Starting container with proper Traefik labels..."
    
    docker run -d \
        --name woswgwcockowgs8k0ocgcwg4-bimaided \
        --network coolify \
        --restart unless-stopped \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.bimaided.rule=Host(\`bimaided.com\`) || Host(\`www.bimaided.com\`)" \
        --label "traefik.http.routers.bimaided.entrypoints=websecure" \
        --label "traefik.http.routers.bimaided.tls=true" \
        --label "traefik.http.routers.bimaided.tls.certresolver=letsencrypt" \
        --label "traefik.http.routers.bimaided-http.rule=Host(\`bimaided.com\`) || Host(\`www.bimaided.com\`)" \
        --label "traefik.http.routers.bimaided-http.entrypoints=web" \
        --label "traefik.http.routers.bimaided-http.middlewares=redirect-to-https" \
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
    echo "3️⃣ Verifying container is running..."
    docker ps | grep bimaided
    
    echo ""
    echo "4️⃣ Checking Traefik configuration..."
    sleep 3
    docker logs coolify-proxy --tail 50 | grep -i bimaided || echo "Waiting for Traefik to pick up changes..."
    
    echo ""
    echo "5️⃣ Testing local connection..."
    docker exec woswgwcockowgs8k0ocgcwg4-bimaided curl -s http://localhost:3000 | head -c 200
ENDSSH

echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Container started with proper Traefik labels!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Your site should now be accessible at:"
echo "   https://bimaided.com"
echo "   http://bimaided.com (will redirect to https)"
echo ""
echo "⏳ Wait 30-60 seconds for:"
echo "   - Traefik to detect the new labels"
echo "   - SSL certificate to be generated"
echo ""
echo "🔍 To check SSL certificate status:"
echo "   ssh root@72.60.222.97"
echo "   docker logs coolify-proxy | grep bimaided"
echo ""
