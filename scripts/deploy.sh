#!/bin/bash

# Manual deployment script for emergencies or initial deployment
# Run this script to manually deploy your application to the VPS

set -e

APP_DIR="/opt/byteforce-test"
IMAGE_NAME="ghcr.io/davechpn/byteforce-test:latest"

echo "🚀 Starting manual deployment..."

# Navigate to application directory
cd $APP_DIR

# Stop current containers
echo "🛑 Stopping current containers..."
docker-compose down

# Pull latest image
echo "📥 Pulling latest image..."
docker pull $IMAGE_NAME

# Start application
echo "▶️ Starting application..."
docker-compose up -d

# Wait for containers to start
echo "⏳ Waiting for containers to start..."
sleep 15

# Check container status
echo "📊 Container status:"
docker-compose ps

# Check logs
echo "📝 Recent logs:"
docker-compose logs --tail=20

# Test application
echo "🔍 Testing application..."
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Application is running successfully!"
else
    echo "❌ Application might not be responding properly"
    echo "Check logs with: docker-compose logs"
fi

echo "🎉 Deployment complete!"