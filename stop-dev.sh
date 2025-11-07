#!/bin/bash

# Stop all BIMSync development servers

echo "🛑 Stopping BIMSync Portal development servers..."

# Kill processes on ports 3001 and 8094
lsof -ti:3001 | xargs kill -9 2>/dev/null && echo "✅ Stopped Admin API (port 3001)" || echo "ℹ️  Admin API was not running"
lsof -ti:8094 | xargs kill -9 2>/dev/null && echo "✅ Stopped Frontend (port 8094)" || echo "ℹ️  Frontend was not running"

# Remove log file
rm -f admin-api.log 2>/dev/null

echo "✅ All development servers stopped"
