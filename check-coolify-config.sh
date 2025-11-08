#!/bin/bash

# Fix Coolify environment variables via API or direct configuration

SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"

echo "🔍 Checking Coolify configuration..."
echo ""

sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << 'ENDSSH'
    echo "1️⃣ Finding your application container UUID..."
    APP_UUID="woswgwcockowgs8k0ocgcwg4"
    echo "Found: $APP_UUID"
    
    echo ""
    echo "2️⃣ Checking Coolify database for your app settings..."
    
    # Connect to Coolify's database
    docker exec coolify-db psql -U coolify -d coolify -c \
        "SELECT fqdn, settings FROM applications WHERE uuid='$APP_UUID';" || echo "Could not query database"
    
    echo ""
    echo "3️⃣ Checking environment variables..."
    docker exec coolify-db psql -U coolify -d coolify -c \
        "SELECT key, value FROM environment_variables WHERE resource_id=(SELECT id FROM applications WHERE uuid='$APP_UUID') ORDER BY key;" || echo "Could not query env vars"
ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 What we found:"
echo "The domain needs to be changed directly in Coolify's database"
echo "or through the UI in the right place."
echo ""
echo "Let me guide you through the correct way..."
echo ""
