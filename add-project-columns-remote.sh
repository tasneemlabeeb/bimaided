#!/bin/bash

# =====================================================
# Add Missing Project Columns on Remote Supabase
# =====================================================

set -e

SERVER_IP="72.60.222.97"
SERVER_USER="root"
SERVER_PASS="lWV,S'8A+&grKvQlQ,7E"

echo "=========================================="
echo "Adding Missing Columns to Projects Table"
echo "=========================================="
echo ""

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "❌ sshpass is not installed."
    echo "   Install it with: brew install sshpass"
    exit 1
fi

echo "📤 Uploading migration script to server..."

# Upload the SQL file to server
export SSHPASS="$SERVER_PASS"
sshpass -e scp -o StrictHostKeyChecking=no \
    database/add-project-columns.sql \
    "$SERVER_USER@$SERVER_IP:/tmp/add-project-columns.sql"

echo "✅ Script uploaded"
echo ""
echo "🔍 Finding Supabase Postgres container..."

# Execute on remote server
sshpass -e ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" << 'ENDSSH'

# Find the Supabase Postgres container
POSTGRES_CONTAINER=$(docker ps --filter "name=supabase-db" --format "{{.Names}}" | head -n 1)

if [ -z "$POSTGRES_CONTAINER" ]; then
    echo "❌ Error: Could not find Supabase Postgres container"
    exit 1
fi

echo "✅ Found container: $POSTGRES_CONTAINER"
echo ""
echo "📋 Running migration..."
echo ""

# Execute the SQL script
docker exec -i "$POSTGRES_CONTAINER" psql -U postgres -d postgres < /tmp/add-project-columns.sql

echo ""
echo "=========================================="
echo "✅ Migration complete!"
echo "=========================================="
echo ""
echo "Added columns to projects table:"
echo "  - category (TEXT)"
echo "  - gallery_image_1 to gallery_image_5 (TEXT)"
echo "  - published (BOOLEAN)"
echo ""

# Clean up
rm /tmp/add-project-columns.sql

ENDSSH

echo "🎉 Done! Projects table is now updated."
echo ""
echo "You can now add projects with categories and gallery images!"
