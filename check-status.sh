#!/bin/bash

# Check status of BIMSync development servers

echo "🔍 Checking BIMSync Portal development servers..."
echo ""

# Check Admin API
if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    echo "✅ Admin API is running on http://localhost:3001"
    curl -s http://localhost:3001/health | jq 2>/dev/null || curl -s http://localhost:3001/health
else
    echo "❌ Admin API is NOT running on port 3001"
fi

echo ""

# Check Frontend
if lsof -ti:8094 > /dev/null 2>&1; then
    echo "✅ Frontend is running on http://localhost:8094"
else
    echo "❌ Frontend is NOT running on port 8094"
fi

echo ""

# Check if admin-api.log exists
if [ -f "admin-api.log" ]; then
    echo "📋 Admin API log file available: admin-api.log"
    echo "   Last 5 lines:"
    tail -n 5 admin-api.log | sed 's/^/   /'
fi
