#!/bin/bash

# 🚀 Automated Upload to Server (72.60.222.97)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Hardcoded server details
SERVER_IP="72.60.222.97"
SERVER_USER="root"
DEST_PATH="/root/bimsync-portal"

echo -e "${BLUE}🚀 BIMSync Portal - Auto Upload to Server${NC}"
echo "========================================"
echo ""
echo "📋 Configuration:"
echo "  Server: $SERVER_USER@$SERVER_IP"
echo "  Destination: $DEST_PATH"
echo ""

echo "📦 Compressing project..."
echo "Excluding: node_modules, .next, .git, build artifacts"
echo ""

# Create archive
ARCHIVE_NAME="bimsync-portal-$(date +%Y%m%d-%H%M%S).tar.gz"

tar --exclude='node_modules' \
    --exclude='.next' \
    --exclude='.git' \
    --exclude='*.log' \
    --exclude='.env.local' \
    --exclude='dist' \
    --exclude='build' \
    --exclude='.DS_Store' \
    --exclude='*.tar.gz' \
    -czf "$ARCHIVE_NAME" .

if [ $? -eq 0 ]; then
    ARCHIVE_SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)
    echo -e "${GREEN}✅ Archive created: $ARCHIVE_NAME ($ARCHIVE_SIZE)${NC}"
else
    echo -e "${RED}❌ Failed to create archive${NC}"
    exit 1
fi

echo ""
echo "📤 Uploading to server $SERVER_IP..."
echo ""

# Upload to server (auto-accept host key)
scp -o StrictHostKeyChecking=no "$ARCHIVE_NAME" "$SERVER_USER@$SERVER_IP:/tmp/"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Upload successful${NC}"
else
    echo -e "${RED}❌ Upload failed${NC}"
    rm "$ARCHIVE_NAME"
    exit 1
fi

echo ""
echo "📂 Extracting on server..."
echo ""

# Extract on server (auto-accept host key)
ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" << 'ENDSSH'
    set -e
    
    DEST_PATH="/root/bimsync-portal"
    
    # Create destination directory
    mkdir -p $DEST_PATH
    
    # Backup existing if it exists
    if [ -d "$DEST_PATH/.next" ] || [ -f "$DEST_PATH/package.json" ]; then
        echo "📦 Backing up existing installation..."
        BACKUP_NAME="$DEST_PATH.backup.$(date +%Y%m%d-%H%M%S)"
        mv $DEST_PATH $BACKUP_NAME
        echo "   Backup saved to: $BACKUP_NAME"
        mkdir -p $DEST_PATH
    fi
    
    # Extract
    echo "📂 Extracting files..."
    ARCHIVE=$(ls -t /tmp/bimsync-portal-*.tar.gz | head -n1)
    tar -xzf $ARCHIVE -C $DEST_PATH
    
    # Clean up
    rm $ARCHIVE
    
    echo ""
    echo -e "\e[32m✅ Files extracted to $DEST_PATH\e[0m"
    
    # Show directory size
    echo ""
    echo "📊 Directory size:"
    du -sh $DEST_PATH
    
    echo ""
    echo "📋 Project files:"
    ls -la $DEST_PATH | head -n 20
ENDSSH

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Extraction successful${NC}"
else
    echo -e "${RED}❌ Extraction failed${NC}"
    rm "$ARCHIVE_NAME"
    exit 1
fi

# Clean up local archive
rm "$ARCHIVE_NAME"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Upload Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo ""
echo "1️⃣  SSH to your server:"
echo -e "   ${YELLOW}ssh $SERVER_USER@$SERVER_IP${NC}"
echo ""
echo "2️⃣  Build Docker image:"
echo -e "   ${YELLOW}cd $DEST_PATH${NC}"
echo -e "   ${YELLOW}docker build -t bimsync-portal:latest .${NC}"
echo ""
echo "3️⃣  Deploy in Coolify:"
echo "   • Dashboard → + New → Docker Image"
echo "   • Image: bimsync-portal:latest"
echo "   • Port: 3000"
echo "   • Add environment variables"
echo "   • Deploy!"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
