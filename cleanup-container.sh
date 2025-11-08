#!/bin/bash

# Stop the direct container to avoid conflicts

SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"

echo "🧹 Cleaning up direct container..."
echo ""

sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << 'ENDSSH'
    echo "Stopping direct container..."
    docker stop bimsync-portal
    docker rm bimsync-portal
    
    echo ""
    echo "✅ Direct container removed"
    echo ""
    echo "Now Coolify can manage the deployment properly"
ENDSSH

echo ""
echo "✅ Done! Now in Coolify:"
echo "1. Make sure domain is set to: bimaided.com"
echo "2. Make sure port is: 3000"
echo "3. Click 'Redeploy'"
echo ""
