#!/bin/bash

# =====================================================
# Setup Storage Buckets on Remote Supabase Instance
# =====================================================

set -e  # Exit on error

SERVER_IP="72.60.222.97"
SERVER_USER="root"
SERVER_PASS="lWV,S'8A+&grKvQlQ,7E"

echo "=========================================="
echo "Setting up Storage Buckets on Production"
echo "=========================================="
echo ""

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "❌ sshpass is not installed."
    echo "   Install it with: brew install sshpass"
    exit 1
fi

echo "📤 Uploading storage setup script to server..."

# Upload the SQL file to server
export SSHPASS="$SERVER_PASS"
sshpass -e scp -o StrictHostKeyChecking=no \
    database/setup-storage-buckets.sql \
    "$SERVER_USER@$SERVER_IP:/tmp/setup-storage-buckets.sql"

echo "✅ Script uploaded"
echo ""
echo "🔍 Finding Supabase Postgres container..."

# Execute on remote server
sshpass -e ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" << 'ENDSSH'

# Find the Supabase Postgres container
POSTGRES_CONTAINER=$(docker ps --filter "name=supabase-db" --format "{{.Names}}" | head -n 1)

if [ -z "$POSTGRES_CONTAINER" ]; then
    echo "❌ Error: Could not find Supabase Postgres container"
    echo "   Available containers:"
    docker ps --format "table {{.Names}}\t{{.Image}}"
    exit 1
fi

echo "✅ Found container: $POSTGRES_CONTAINER"
echo ""
echo "📋 Running storage setup script..."
echo ""

# Execute the SQL script
docker exec -i "$POSTGRES_CONTAINER" psql -U postgres -d postgres < /tmp/setup-storage-buckets.sql

echo ""
echo "=========================================="
echo "✅ Storage buckets setup complete!"
echo "=========================================="
echo ""
echo "Created buckets:"
echo "  1. employee-photos (Private, 5MB)"
echo "  2. employee-documents (Private, 10MB)"
echo "  3. cvs (Private, 10MB)"
echo "  4. project-images (Public, 10MB) ← Fixes upload error"
echo "  5. leave-attachments (Private, 10MB)"
echo ""
echo "🧪 Test by uploading a project image at:"
echo "   https://bimaided.com/admin"
echo ""

# Clean up
rm /tmp/setup-storage-buckets.sql

ENDSSH

echo "🎉 Done! Storage is now configured."
echo ""
echo "Next steps:"
echo "  1. Go to https://bimaided.com/admin"
echo "  2. Navigate to Projects tab"
echo "  3. Try adding a project with images"
echo "  4. Upload should work now! ✅"
