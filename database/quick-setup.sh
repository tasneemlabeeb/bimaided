#!/bin/bash

# ============================================
# BIM Portal - Coolify Deployment Setup
# ============================================

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         BIM Portal - Coolify Full Stack Setup             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if .env file exists
if [ ! -f "../.env" ]; then
    echo "❌ Error: .env file not found in parent directory"
    echo "   Please create .env file with Supabase credentials"
    exit 1
fi

echo "✅ Environment file found"
echo ""

# Load environment variables
source ../.env

echo "🔗 Supabase URL: $VITE_SUPABASE_URL"
echo ""

# Options menu
echo "Choose setup option:"
echo ""
echo "  1. 📋 Display required database migrations"
echo "  2. 🚀 Show Coolify deployment guide"
echo "  3. 📄 Display complete production schema"
echo "  4. 🔧 Environment variables checklist"
echo "  5. Exit"
echo ""
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "� Required Database Migrations"
        echo "==============================="
        echo ""
        echo "Execute these files in your Supabase SQL Editor in order:"
        echo "$VITE_SUPABASE_URL/project/default/sql"
        echo ""
        
        migrations=(
            "16_create_job_applications_table.sql:Create job applications table and policies"
            "17_verify_projects_table.sql:Add missing columns to projects table"
            "15_create_assignments_tables.sql:Create assignments system tables"
            "18_create_storage_buckets.sql:Setup storage buckets and policies"
        )
        
        for i in "${!migrations[@]}"; do
            IFS=':' read -r file description <<< "${migrations[$i]}"
            num=$((i + 1))
            echo "[$num] $description"
            echo "    File: $file"
            
            if [ -f "$file" ]; then
                echo "    Status: ✅ File found"
            else
                echo "    Status: ❌ File not found"
            fi
            echo ""
        done
        
        echo "💡 Alternative: Use complete_production_schema.sql for fresh installation"
        ;;
    2)
        echo ""
        echo "🚀 Coolify Deployment Guide"
        echo "==========================="
        echo ""
        echo "1. 📝 Create New Application in Coolify:"
        echo "   - Repository: https://github.com/tasneemlabeeb/bimsync-portal.git"
        echo "   - Branch: main"
        echo "   - Build Pack: Docker"
        echo "   - Dockerfile: Dockerfile.coolify"
        echo "   - Port: 3001"
        echo ""
        echo "2. 🌐 Environment Variables (copy from .env.coolify):"
        echo "   - NODE_ENV=production"
        echo "   - PORT=3001"
        echo "   - All Supabase URLs and keys"
        echo "   - Email configuration"
        echo ""
        echo "3. 🔗 Set Custom Domain:"
        echo "   - Add your domain in Coolify"
        echo "   - Update VITE_API_URL to your domain"
        echo "   - Enable SSL (Let's Encrypt)"
        echo ""
        echo "4. 🚀 Deploy and Test:"
        echo "   - Frontend: https://your-domain.com"
        echo "   - API: https://your-domain.com/api/health"
        echo "   - Admin: https://your-domain.com/admin"
        echo ""
        ;;
    3)
        echo ""
        echo "📄 Complete Production Schema"
        echo "============================"
        echo ""
        echo "For fresh database setup, use complete_production_schema.sql"
        echo ""
        if [ -f "complete_production_schema.sql" ]; then
            echo "✅ File found: complete_production_schema.sql"
            echo "📏 File size: $(wc -l < complete_production_schema.sql) lines"
            echo ""
            echo "This file contains:"
            echo "  ✓ All tables and relationships"
            echo "  ✓ RLS policies and security"
            echo "  ✓ Functions and triggers"
            echo "  ✓ Sample data for testing"
            echo "  ✓ Storage buckets and policies"
        else
            echo "❌ File not found: complete_production_schema.sql"
        fi
        ;;
    4)
        echo ""
        echo "🔧 Environment Variables Checklist"
        echo "=================================="
        echo ""
        
        required_vars=(
            "NODE_ENV:production"
            "PORT:3001"
            "VITE_SUPABASE_URL:$VITE_SUPABASE_URL"
            "VITE_SUPABASE_ANON_KEY:Present"
            "SUPABASE_SERVICE_KEY:Present"
            "DATABASE_URL:Internal Coolify connection"
            "JWT_SECRET:Random secure string"
            "EMAIL_USER:Gmail address"
            "EMAIL_PASSWORD:App password"
            "VITE_API_URL:Your deployed domain"
        )
        
        echo "Required for Coolify deployment:"
        echo ""
        for var in "${required_vars[@]}"; do
            IFS=':' read -r key value <<< "$var"
            echo "  $key: $value"
        done
        
        echo ""
        echo "📋 Copy all values from .env.coolify to your Coolify app"
        ;;
    5)
        echo ""
        echo "👋 Exiting..."
        exit 0
        ;;
    *)
        echo ""
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                  Migration Complete!                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Next Steps:"
echo ""
echo "  1. Verify tables in Supabase Dashboard:"
echo "     http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io"
echo ""
echo "  2. Create your first admin user (see README.md)"
echo ""
echo "  3. Start your application:"
echo "     cd .."
echo "     npm run dev"
echo ""
echo "📚 Documentation: database/README.md"
echo ""
