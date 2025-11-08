#!/bin/bash

# Coolify Pre-Deployment Checker for BIMSync Portal

echo "🔍 Coolify Deployment Readiness Check"
echo "======================================"
echo ""

# Check 1: Git repository
echo "📦 Checking Git repository..."
if [ -d .git ]; then
    echo "   ✅ Git repository found"
    
    # Check for uncommitted changes
    if [[ -n $(git status -s) ]]; then
        echo "   ⚠️  You have uncommitted changes"
        echo "   Run: git add . && git commit -m 'Ready for deployment'"
    else
        echo "   ✅ No uncommitted changes"
    fi
    
    # Check remote
    if git remote -v | grep -q origin; then
        echo "   ✅ Remote origin configured"
        echo "   Remote: $(git remote get-url origin)"
    else
        echo "   ⚠️  No remote origin found"
        echo "   Run: git remote add origin <your-github-url>"
    fi
else
    echo "   ❌ Not a git repository"
    echo "   Run: git init && git add . && git commit -m 'Initial commit'"
fi
echo ""

# Check 2: Dockerfile
echo "🐳 Checking Dockerfile..."
if [ -f Dockerfile ]; then
    echo "   ✅ Dockerfile found"
    
    # Check for EXPOSE
    if grep -q "EXPOSE 3000" Dockerfile; then
        echo "   ✅ Port 3000 exposed"
    else
        echo "   ⚠️  Port 3000 not found in Dockerfile"
    fi
    
    # Check for standalone output requirement
    if grep -q "standalone" next.config.mjs; then
        echo "   ✅ Next.js standalone output configured"
    else
        echo "   ⚠️  Standalone output not configured"
    fi
else
    echo "   ❌ Dockerfile not found"
fi
echo ""

# Check 3: Environment variables
echo "🔐 Checking environment setup..."
if [ -f .env ]; then
    echo "   ✅ .env file found"
    echo "   ⚠️  Remember to add these to Coolify:"
    echo ""
    echo "   Required variables:"
    echo "   - NEXT_PUBLIC_SUPABASE_URL"
    echo "   - NEXT_PUBLIC_SUPABASE_ANON_KEY"
    echo ""
else
    echo "   ⚠️  No .env file found (OK for production)"
fi

if [ -f .env.example ]; then
    echo "   ✅ .env.example found (good for reference)"
else
    echo "   ⚠️  Consider creating .env.example for documentation"
fi
echo ""

# Check 4: Dependencies
echo "📚 Checking dependencies..."
if [ -f package.json ]; then
    echo "   ✅ package.json found"
    
    if [ -f package-lock.json ]; then
        echo "   ✅ package-lock.json found"
    elif [ -f yarn.lock ]; then
        echo "   ✅ yarn.lock found"
    else
        echo "   ⚠️  No lock file found - run npm install"
    fi
else
    echo "   ❌ package.json not found"
fi
echo ""

# Check 5: Next.js config
echo "⚙️  Checking Next.js configuration..."
if [ -f next.config.mjs ] || [ -f next.config.js ]; then
    echo "   ✅ Next.js config found"
else
    echo "   ❌ Next.js config not found"
fi
echo ""

# Summary
echo "======================================"
echo "📋 Pre-Deployment Summary"
echo "======================================"
echo ""
echo "✅ Ready for Coolify deployment if all checks passed!"
echo ""
echo "🚀 Next Steps:"
echo "   1. Push code to GitHub"
echo "   2. Install Coolify on your server"
echo "   3. Create new app in Coolify dashboard"
echo "   4. Connect your GitHub repository"
echo "   5. Set environment variables"
echo "   6. Deploy!"
echo ""
echo "📖 Full guide: Read COOLIFY_DEPLOYMENT.md"
echo ""
