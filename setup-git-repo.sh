#!/bin/bash

echo "🚀 Setting up new Git repository..."

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Add storage policies for project images"

# Prompt for remote repository URL
echo ""
echo "📝 Please enter your remote repository URL (e.g., https://github.com/username/repo.git):"
read remote_url

if [ -z "$remote_url" ]; then
    echo "❌ No URL provided. Exiting."
    exit 1
fi

# Add remote origin
git remote add origin "$remote_url"

# Push to remote (create main branch)
echo ""
echo "🔄 Pushing to remote repository..."
git branch -M main
git push -u origin main

echo ""
echo "✅ Repository successfully pushed to $remote_url"
