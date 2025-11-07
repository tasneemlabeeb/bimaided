#!/bin/bash

# BIMSync Portal Development Startup Script
# This script starts both the Admin API and Frontend dev servers

echo "🚀 Starting BIMSync Portal Development Environment..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if admin-api directory exists
if [ ! -d "admin-api" ]; then
    echo -e "${RED}❌ Error: admin-api directory not found!${NC}"
    echo "Make sure you're in the project root directory"
    exit 1
fi

# Check if .env file exists in admin-api
if [ ! -f "admin-api/.env" ]; then
    echo -e "${RED}❌ Error: admin-api/.env file not found!${NC}"
    echo "Please create admin-api/.env with your SERVICE_ROLE key"
    exit 1
fi

# Kill any existing processes on ports 3001 and 8094
echo "🧹 Cleaning up existing processes..."
lsof -ti:3001 | xargs kill -9 2>/dev/null || true
lsof -ti:8094 | xargs kill -9 2>/dev/null || true
sleep 1

# Start Admin API in background
echo -e "${BLUE}📡 Starting Admin API on port 3001...${NC}"
cd admin-api
npm run dev > ../admin-api.log 2>&1 &
ADMIN_API_PID=$!
cd ..

# Wait for admin API to start
echo "⏳ Waiting for Admin API to be ready..."
for i in {1..10}; do
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Admin API is running on http://localhost:3001${NC}"
        break
    fi
    if [ $i -eq 10 ]; then
        echo -e "${RED}❌ Admin API failed to start. Check admin-api.log for errors${NC}"
        exit 1
    fi
    sleep 1
done

# Start Frontend dev server
echo -e "${BLUE}🎨 Starting Frontend on port 8094...${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✨ BIMSync Portal is starting...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📡 Admin API:  http://localhost:3001"
echo "  🌐 Frontend:   http://localhost:8094"
echo ""
echo "  📋 To view Admin API logs: tail -f admin-api.log"
echo "  🛑 To stop: Press Ctrl+C or run ./stop-dev.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start frontend (this will run in foreground)
npm run dev

# If npm run dev exits, cleanup
echo ""
echo "🛑 Shutting down Admin API..."
kill $ADMIN_API_PID 2>/dev/null || true
echo "✅ Development servers stopped"
