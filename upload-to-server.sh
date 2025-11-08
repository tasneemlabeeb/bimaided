#!/bin/bash

# 🚀 Upload BIMSync Portal to Server
# This will compress and upload your project to your Coolify server

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 BIMSync Portal - Server Upload Script${NC}"
echo "========================================"
echo ""

# Ask for server details
echo -e "${YELLOW}Enter your server IP address:${NC}"
read -r SERVER_IP

echo -e "${YELLOW}Enter SSH username (usually 'root'):${NC}"
read -r SERVER_USER

echo -e "${YELLOW}Enter destination path on server (default: /root/bimsync-portal):${NC}"
read -r DEST_PATH
DEST_PATH=${DEST_PATH:-/root/bimsync-portal}

echo ""
echo "📋 Configuration:"
echo "  Server: $SERVER_USER@$SERVER_IP"
echo "  Destination: $DEST_PATH"
echo ""
echo -e "${YELLOW}Is this correct? (y/n)${NC}"
read -r confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "📦 Step 1: Compressing project..."
echo "Excluding: node_modules, .next, .git, build artifacts"
echo ""

# Create temporary archive
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
echo "📤 Step 2: Uploading to server..."
echo ""

# Upload to server
scp "$ARCHIVE_NAME" "$SERVER_USER@$SERVER_IP:/tmp/"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Upload successful${NC}"
else
    echo -e "${RED}❌ Upload failed${NC}"
    rm "$ARCHIVE_NAME"
    exit 1
fi

echo ""
echo "📂 Step 3: Extracting on server..."
echo ""

# Extract on server
ssh "$SERVER_USER@$SERVER_IP" << EOF
    set -e
    
    # Create destination directory
    mkdir -p $DEST_PATH
    
    # Backup existing if it exists
    if [ -d "$DEST_PATH/.next" ]; then
        echo "📦 Backing up existing installation..."
        mv $DEST_PATH $DEST_PATH.backup.\$(date +%Y%m%d-%H%M%S)
        mkdir -p $DEST_PATH
    fi
    
    # Extract
    echo "📂 Extracting files..."
    tar -xzf /tmp/$ARCHIVE_NAME -C $DEST_PATH
    
    # Clean up
    rm /tmp/$ARCHIVE_NAME
    
    echo "✅ Files extracted to $DEST_PATH"
    
    # Show directory size
    echo ""
    echo "📊 Directory size:"
    du -sh $DEST_PATH
    
    echo ""
    echo "📋 Files:"
    ls -la $DEST_PATH | head -n 15
EOF

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
echo -e "${GREEN}🎉 Upload Complete!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Next Steps:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  SSH to your server:"
echo -e "   ${YELLOW}ssh $SERVER_USER@$SERVER_IP${NC}"
echo ""
echo "2️⃣  Navigate to project:"
echo -e "   ${YELLOW}cd $DEST_PATH${NC}"
echo ""
echo "3️⃣  Build Docker image:"
echo -e "   ${YELLOW}docker build -t bimsync-portal:latest .${NC}"
echo ""
echo "4️⃣  Deploy in Coolify:"
echo "   • Open Coolify Dashboard"
echo "   • Click '+ New' → 'Docker Image'"
echo "   • Image: bimsync-portal:latest"
echo "   • Port: 3000"
echo "   • Add environment variables"
echo "   • Click 'Deploy'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}Would you like to SSH to the server now? (y/n)${NC}"
read -r ssh_now

if [[ "$ssh_now" =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔐 Connecting to server..."
    echo ""
    ssh "$SERVER_USER@$SERVER_IP"
fi
