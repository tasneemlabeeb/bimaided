#!/bin/bash

# 🚀 Upload with Password Authentication

set -e

# Server details
SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"
DEST_PATH="/root/bimsync-portal"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 BIMSync Portal - Upload to Server${NC}"
echo "========================================"
echo ""
echo "📋 Server: $SERVER_USER@$SERVER_IP"
echo "📁 Destination: $DEST_PATH"
echo ""

# Create archive
echo "📦 Creating archive..."
tar --exclude='node_modules' \
    --exclude='.next' \
    --exclude='.git' \
    --exclude='*.log' \
    --exclude='.env.local' \
    --exclude='*.tar.gz' \
    -czf /tmp/bimsync-upload.tar.gz .

ARCHIVE_SIZE=$(du -h /tmp/bimsync-upload.tar.gz | cut -f1)
echo -e "${GREEN}✅ Archive created: $ARCHIVE_SIZE${NC}"
echo ""

# Upload
echo "📤 Uploading to server..."
sshpass -e scp -o StrictHostKeyChecking=no /tmp/bimsync-upload.tar.gz $SERVER_USER@$SERVER_IP:/tmp/

echo -e "${GREEN}✅ Upload complete${NC}"
echo ""

# Extract on server
echo "📂 Extracting on server..."
sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << 'ENDSSH'
    set -e
    
    DEST_PATH="/root/bimsync-portal"
    
    # Backup if exists
    if [ -f "$DEST_PATH/package.json" ]; then
        echo "📦 Backing up existing installation..."
        BACKUP="$DEST_PATH.backup.$(date +%Y%m%d-%H%M%S)"
        mv "$DEST_PATH" "$BACKUP"
        echo "   Saved to: $BACKUP"
    fi
    
    # Create and extract
    mkdir -p "$DEST_PATH"
    echo "📂 Extracting..."
    tar -xzf /tmp/bimsync-upload.tar.gz -C "$DEST_PATH"
    rm /tmp/bimsync-upload.tar.gz
    
    echo ""
    echo "✅ Extraction complete"
    echo ""
    echo "📊 Directory size:"
    du -sh "$DEST_PATH"
    echo ""
    echo "📋 Files:"
    ls -la "$DEST_PATH" | head -n 15
ENDSSH

# Clean up
rm /tmp/bimsync-upload.tar.gz

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Upload Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo ""
echo "1️⃣  Build Docker image on server:"
echo -e "   ${YELLOW}sshpass -e ssh $SERVER_USER@$SERVER_IP${NC}"
echo -e "   ${YELLOW}cd $DEST_PATH${NC}"
echo -e "   ${YELLOW}docker build -t bimsync-portal:latest .${NC}"
echo ""
echo "2️⃣  In Coolify Dashboard:"
echo "   • + New → Docker Image"
echo "   • Image: bimsync-portal:latest"
echo "   • Port: 3000"
echo "   • Add environment variables"
echo "   • Deploy!"
echo ""
echo -e "${YELLOW}Run build now? This will SSH to server and build. (y/n)${NC}"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔨 Building Docker image on server..."
    echo ""
    sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << 'ENDBUILD'
        cd /root/bimsync-portal
        echo "Building Docker image (this takes 2-3 minutes)..."
        docker build -t bimsync-portal:latest .
        echo ""
        echo "✅ Build complete!"
        echo ""
        echo "📦 Docker image:"
        docker images | grep bimsync
ENDBUILD
    
    echo ""
    echo -e "${GREEN}🎉 Ready to deploy in Coolify!${NC}"
fi
