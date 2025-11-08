#!/bin/bash

# 🚀 BIMSync Portal - Local Docker Build & Test
# Run this on your Mac before deploying to Coolify

set -e

echo "🎯 BIMSync Portal - Docker Build Script"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is running
echo "🔍 Checking Docker Desktop..."
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker Desktop is not running!${NC}"
    echo "Please start Docker Desktop and try again."
    exit 1
fi
echo -e "${GREEN}✅ Docker Desktop is running${NC}"
echo ""

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}❌ Dockerfile not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dockerfile found${NC}"
echo ""

# Clean up old builds
echo "🧹 Cleaning up old builds..."
docker image rm bimsync-portal:latest 2>/dev/null || true
echo ""

# Build the image
echo "🔨 Building Docker image..."
echo "This may take a few minutes..."
echo ""

docker build -t bimsync-portal:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo ""
else
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

# Show image info
echo "📦 Docker Image Info:"
docker images bimsync-portal:latest
echo ""

# Ask if user wants to test locally
echo -e "${YELLOW}Would you like to test the container locally? (y/n)${NC}"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Starting container locally on port 3000..."
    
    # Stop existing container if running
    docker stop bimsync-portal-test 2>/dev/null || true
    docker rm bimsync-portal-test 2>/dev/null || true
    
    # Run the container
    docker run -d \
        --name bimsync-portal-test \
        -p 3000:3000 \
        -e NODE_ENV=production \
        -e NEXT_PUBLIC_SUPABASE_URL="${NEXT_PUBLIC_SUPABASE_URL}" \
        -e NEXT_PUBLIC_SUPABASE_ANON_KEY="${NEXT_PUBLIC_SUPABASE_ANON_KEY}" \
        bimsync-portal:latest
    
    echo ""
    echo -e "${GREEN}✅ Container started!${NC}"
    echo ""
    echo "📱 Access your app at: http://localhost:3000"
    echo ""
    echo "📋 Useful commands:"
    echo "  View logs:    docker logs -f bimsync-portal-test"
    echo "  Stop:         docker stop bimsync-portal-test"
    echo "  Remove:       docker rm bimsync-portal-test"
    echo ""
    
    # Wait a bit then show logs
    sleep 3
    echo "📝 Container logs (last 20 lines):"
    docker logs --tail 20 bimsync-portal-test
fi

echo ""
echo -e "${GREEN}🎉 All done!${NC}"
echo ""
echo "Next steps for Coolify deployment:"
echo "1. Save/export this image: docker save bimsync-portal:latest | gzip > bimsync-portal.tar.gz"
echo "2. Or push to Docker Hub: docker tag bimsync-portal:latest yourusername/bimsync-portal:latest"
echo "3. Or transfer directly to your server (we'll do this together)"
echo ""
