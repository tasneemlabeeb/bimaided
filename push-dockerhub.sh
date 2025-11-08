#!/bin/bash

# Push BIMSync Portal image to Docker Hub

SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"
DOCKER_PASSWORD="C?18dr!4docker"

echo "🚀 Pushing Docker image to Docker Hub"
echo "======================================"
echo ""
read -p "Enter your Docker Hub Username: " DOCKER_USERNAME
echo ""

echo "📤 Connecting to server and pushing image..."
echo ""

sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << ENDSSH
    set -e
    
    echo "🔐 Logging into Docker Hub..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    
    if [ \$? -eq 0 ]; then
        echo "✅ Login successful!"
    else
        echo "❌ Login failed!"
        exit 1
    fi
    
    echo ""
    echo "🏷️  Tagging image..."
    docker tag bimsync-portal:latest $DOCKER_USERNAME/bimsync-portal:latest
    
    echo ""
    echo "📤 Pushing to Docker Hub (this may take 2-3 minutes)..."
    docker push $DOCKER_USERNAME/bimsync-portal:latest
    
    echo ""
    echo "✅ Push complete!"
    echo ""
    echo "📦 Your image is now available at:"
    echo "   docker pull $DOCKER_USERNAME/bimsync-portal:latest"
ENDSSH

if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Image pushed to Docker Hub!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 Now deploy in Coolify:"
    echo ""
    echo "1. Go to Coolify Dashboard"
    echo "2. Click: + New → Resource"
    echo "3. Choose: Docker Based → Docker Image"
    echo "4. Fill in:"
    echo "   Image: $DOCKER_USERNAME/bimsync-portal:latest"
    echo "   Port: 3000"
    echo "5. Add all environment variables"
    echo "6. Click Deploy!"
    echo ""
fi
