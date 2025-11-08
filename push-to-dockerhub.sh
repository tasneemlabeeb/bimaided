#!/bin/bash

# Push BIMSync Portal image to Docker Hub

SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"

echo "🚀 Pushing Docker image to Docker Hub"
echo "======================================"
echo ""
echo "First, we need your Docker Hub credentials:"
echo ""
read -p "Docker Hub Username: " DOCKER_USERNAME
read -sp "Docker Hub Password: " DOCKER_PASSWORD
echo ""
echo ""

echo "📤 Connecting to server and pushing image..."
echo ""

sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << ENDSSH
    set -e
    
    echo "🔐 Logging into Docker Hub..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    
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
    echo "   $DOCKER_USERNAME/bimsync-portal:latest"
ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Image pushed to Docker Hub!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Now in Coolify Dashboard:"
echo ""
echo "1. Click: + New → Resource"
echo "2. Choose: Docker Based → Docker Image"
echo "3. Enter Image: $DOCKER_USERNAME/bimsync-portal:latest"
echo "4. Port: 3000"
echo "5. Add environment variables"
echo "6. Deploy!"
echo ""
