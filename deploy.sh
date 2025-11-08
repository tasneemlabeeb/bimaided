#!/bin/bash

# BIMSync Portal - Quick Deploy Script

echo "🚀 BIMSync Portal Deployment"
echo "=============================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Check for .env file
if [ ! -f .env ]; then
    echo "⚠️  No .env file found!"
    echo "   Creating .env from example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ Created .env file. Please edit it with your credentials."
        echo ""
        read -p "Press enter to continue after editing .env file..."
    else
        echo "❌ No .env.example file found. Please create .env manually."
        exit 1
    fi
fi

echo "📦 Building and starting containers..."
echo ""

# Build and start
docker-compose up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "🌐 Application is running at: http://localhost:3000"
    echo ""
    echo "📊 View logs: docker-compose logs -f"
    echo "🛑 Stop app: docker-compose down"
    echo ""
else
    echo ""
    echo "❌ Deployment failed. Check the logs above."
    exit 1
fi
