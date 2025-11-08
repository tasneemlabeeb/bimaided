#!/bin/bash

# Production Deployment Script for BIMaided
# This script builds and deploys the application to bimaided.com

set -e  # Exit on error

echo "🚀 BIMaided Production Deployment"
echo "=================================="
echo ""

# Check if reCAPTCHA keys are still test keys
if grep -q "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI" .env.local; then
    echo "⚠️  WARNING: You are using TEST reCAPTCHA keys!"
    echo "   Get production keys from: https://www.google.com/recaptcha/admin"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled."
        exit 1
    fi
fi

# Load environment variables from .env.local
echo "📋 Loading environment variables..."

# Read specific values we need
NEXT_PUBLIC_SUPABASE_URL=$(grep "^NEXT_PUBLIC_SUPABASE_URL=" .env.local | cut -d '=' -f2-)
NEXT_PUBLIC_SUPABASE_ANON_KEY=$(grep "^NEXT_PUBLIC_SUPABASE_ANON_KEY=" .env.local | cut -d '=' -f2-)
SUPABASE_SERVICE_KEY=$(grep "^SUPABASE_SERVICE_KEY=" .env.local | cut -d '=' -f2-)
EMAIL_USER=$(grep "^EMAIL_USER=" .env.local | cut -d '=' -f2-)
EMAIL_PASSWORD=$(grep "^EMAIL_PASSWORD=" .env.local | cut -d '=' -f2-)
EMAIL_TO=$(grep "^EMAIL_TO=" .env.local | cut -d '=' -f2-)
NEXT_PUBLIC_RECAPTCHA_SITE_KEY=$(grep "^NEXT_PUBLIC_RECAPTCHA_SITE_KEY=" .env.local | cut -d '=' -f2-)
RECAPTCHA_SECRET_KEY=$(grep "^RECAPTCHA_SECRET_KEY=" .env.local | cut -d '=' -f2-)

# Validate required variables
if [ -z "$NEXT_PUBLIC_SUPABASE_URL" ]; then
    echo "❌ Error: NEXT_PUBLIC_SUPABASE_URL not set in .env.local"
    exit 1
fi

if [ -z "$NEXT_PUBLIC_RECAPTCHA_SITE_KEY" ]; then
    echo "❌ Error: NEXT_PUBLIC_RECAPTCHA_SITE_KEY not set in .env.local"
    exit 1
fi

echo "✅ Environment variables loaded"
echo ""

# Build Docker image
echo "🏗️  Building Docker image..."
docker build -t tasneemlabeeb/bimsync-portal:latest .

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed!"
    exit 1
fi

echo "✅ Docker image built successfully"
echo ""

# Push to Docker Hub
echo "📤 Pushing to Docker Hub..."
docker push tasneemlabeeb/bimsync-portal:latest

if [ $? -ne 0 ]; then
    echo "❌ Docker push failed!"
    exit 1
fi

echo "✅ Image pushed to Docker Hub"
echo ""

# Deploy to production server
echo "🚢 Deploying to production server (bimaided.com)..."
export SSHPASS='lWV,S'"'"'8A+&grKvQlQ,7E'
sshpass -e ssh -o StrictHostKeyChecking=no root@72.60.222.97 << ENDSSH
echo "Pulling latest image..."
docker pull tasneemlabeeb/bimsync-portal:latest

echo ""
echo "Stopping current container..."
docker stop bimsync-portal-live 2>/dev/null || echo "No container to stop"
docker rm bimsync-portal-live 2>/dev/null || echo "No container to remove"

echo ""
echo "Starting production container..."
docker run -d \
    --name bimsync-portal-live \
    --network coolify \
    --restart unless-stopped \
    --label "traefik.enable=true" \
    --label "traefik.http.routers.bimaided-https.rule=Host(\\\`bimaided.com\\\`) || Host(\\\`www.bimaided.com\\\`)" \
    --label "traefik.http.routers.bimaided-https.entrypoints=https" \
    --label "traefik.http.routers.bimaided-https.tls=true" \
    --label "traefik.http.routers.bimaided-https.tls.certresolver=letsencrypt" \
    --label "traefik.http.routers.bimaided-http.rule=Host(\\\`bimaided.com\\\`) || Host(\\\`www.bimaided.com\\\`)" \
    --label "traefik.http.routers.bimaided-http.entrypoints=http" \
    --label "traefik.http.services.bimaided.loadbalancer.server.port=3000" \
    -e NODE_ENV=production \
    -e NEXT_PUBLIC_SUPABASE_URL="${NEXT_PUBLIC_SUPABASE_URL}" \
    -e NEXT_PUBLIC_SUPABASE_ANON_KEY="${NEXT_PUBLIC_SUPABASE_ANON_KEY}" \
    -e SUPABASE_SERVICE_KEY="${SUPABASE_SERVICE_KEY}" \
    -e EMAIL_USER="${EMAIL_USER}" \
    -e EMAIL_PASSWORD="${EMAIL_PASSWORD}" \
    -e EMAIL_TO="${EMAIL_TO}" \
    -e NEXT_PUBLIC_RECAPTCHA_SITE_KEY="${NEXT_PUBLIC_RECAPTCHA_SITE_KEY}" \
    -e RECAPTCHA_SECRET_KEY="${RECAPTCHA_SECRET_KEY}" \
    -e NEXT_PUBLIC_APP_URL="https://bimaided.com" \
    tasneemlabeeb/bimsync-portal:latest

echo ""
echo "Waiting for container to start..."
sleep 8

echo ""
echo "Container status:"
docker ps | grep bimsync-portal-live

echo ""
echo "Recent container logs:"
docker logs --tail 20 bimsync-portal-live

ENDSSH

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed!"
    exit 1
fi

echo ""
echo "✅ Deployment successful!"
echo ""
echo "🌐 Website: https://bimaided.com"
echo "📧 Test contact form: https://bimaided.com/contact"
echo "🔐 Admin dashboard: https://bimaided.com/admin"
echo ""
echo "📊 Monitor logs with:"
echo "   ssh root@72.60.222.97 'docker logs -f bimsync-portal-live'"
echo ""
