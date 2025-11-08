#!/bin/bash

# Save the image to a tar file
echo "Saving Docker image to tar file..."
docker save tasneemlabeeb/bimsync-portal:latest | gzip > bimsync-portal-latest.tar.gz

# Upload to server
echo "Uploading to server..."
export SSHPASS='lWV,S'"'"'8A+&grKvQlQ,7E'
sshpass -e scp bimsync-portal-latest.tar.gz root@72.60.222.97:/root/

# Load on server and restart container
echo "Loading image on server..."
sshpass -e ssh -o StrictHostKeyChecking=no root@72.60.222.97 << 'ENDSSH'
cd /root
gunzip -c bimsync-portal-latest.tar.gz | docker load
rm bimsync-portal-latest.tar.gz

echo "Stopping current container..."
docker stop bimsync-portal-live 2>/dev/null || true
docker rm bimsync-portal-live 2>/dev/null || true

echo "Starting updated container..."
docker run -d \
    --name bimsync-portal-live \
    --network coolify \
    --restart unless-stopped \
    --label "traefik.enable=true" \
    --label "traefik.http.routers.bimaided-https.rule=Host(\`bimaided.com\`) || Host(\`www.bimaided.com\`)" \
    --label "traefik.http.routers.bimaided-https.entrypoints=https" \
    --label "traefik.http.routers.bimaided-https.tls=true" \
    --label "traefik.http.routers.bimaided-https.tls.certresolver=letsencrypt" \
    --label "traefik.http.routers.bimaided-http.rule=Host(\`bimaided.com\`) || Host(\`www.bimaided.com\`)" \
    --label "traefik.http.routers.bimaided-http.entrypoints=http" \
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
echo "Container restarted! Waiting 5 seconds..."
sleep 5
docker ps | grep bimsync-portal-live
ENDSSH

# Cleanup local tar file
echo "Cleaning up..."
rm bimsync-portal-latest.tar.gz

echo ""
echo "✅ Deployment complete!"
echo "Website: https://bimaided.com"
