#!/bin/bash

# Deploy BIMSync Portal directly with Docker (bypass Coolify for now)

SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"

echo "🚀 Deploying BIMSync Portal directly on server..."
echo ""

sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << 'ENDSSH'
    set -e
    
    echo "📋 Stopping any existing container..."
    docker stop bimsync-portal 2>/dev/null || true
    docker rm bimsync-portal 2>/dev/null || true
    
    echo ""
    echo "🚀 Starting BIMSync Portal container..."
    docker run -d \
        --name bimsync-portal \
        --restart unless-stopped \
        -p 3000:3000 \
        -e NODE_ENV=production \
        -e NEXT_PUBLIC_SUPABASE_URL="http://supabasekong-n4g4og0cos0ocwg0ss8cswss.72.60.222.97.sslip.io" \
        -e NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoiYW5vbiJ9.TuGXG83THiqENV8Nern5GwkiS7R6OCY4SGcB9cD-6XE" \
        -e SUPABASE_SERVICE_KEY="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoic2VydmljZV9yb2xlIn0.-X1sUGnaBrVLPeh3ZTgJN5SqEb55aI_mauvyKUyE4P8" \
        -e EMAIL_USER="bimaided.website@gmail.com" \
        -e EMAIL_PASSWORD="rwgy biho ilda memw" \
        -e EMAIL_TO="tasneemlabeeb@gmail.com" \
        -e NEXT_PUBLIC_RECAPTCHA_SITE_KEY="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI" \
        bimsync-portal:latest
    
    echo ""
    echo "✅ Container started!"
    echo ""
    echo "📋 Container status:"
    docker ps | grep bimsync
    
    echo ""
    echo "Waiting for app to start..."
    sleep 5
    
    echo ""
    echo "📝 Container logs:"
    docker logs --tail 20 bimsync-portal
    
    echo ""
    echo "✅ Deployment complete!"
    echo ""
    echo "🌐 Your app is now live at:"
    echo "   http://72.60.222.97:3000"
    echo ""
    echo "📊 To check status:"
    echo "   docker ps"
    echo "   docker logs -f bimsync-portal"
ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Access your app:"
echo "   http://72.60.222.97:3000"
echo ""
echo "Later you can set up a domain and SSL with Nginx/Caddy"
echo "or use Coolify's proxy features to manage it."
echo ""
