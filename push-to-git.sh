#!/bin/bash

# Add all changes
git add .

# Commit with a message
echo "Enter commit message (or press Enter for default message):"
read commit_message

if [ -z "$commit_message" ]; then
    commit_message="Update files"
fi

git commit -m "$commit_message"

# Push to remote
git push

echo "✅ Changes pushed to git successfully!"
