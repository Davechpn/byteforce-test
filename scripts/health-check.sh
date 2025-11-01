#!/bin/bash

# Monitoring and maintenance script for your VPS
# Run this periodically to check system health

echo "🔍 System Health Check"
echo "====================="

# Check disk usage
echo "💾 Disk Usage:"
df -h | grep -E "(Filesystem|/dev/)"

echo ""

# Check memory usage
echo "🧠 Memory Usage:"
free -h

echo ""

# Check Docker containers
echo "🐳 Docker Containers:"
docker ps

echo ""

# Check Docker images and clean up
echo "🗑️ Docker Images:"
docker images
echo ""
echo "Cleaning up unused Docker images..."
docker image prune -f

echo ""

# Check application logs
echo "📝 Application Logs (last 10 lines):"
cd /opt/byteforce-test
docker-compose logs --tail=10

echo ""

# Check nginx status if using nginx
echo "🌐 Nginx Status:"
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx is running"
else
    echo "❌ Nginx is not running"
fi

echo ""

# Check SSL certificate expiry (if using Let's Encrypt)
echo "🔒 SSL Certificate Status:"
if [ -f "/etc/letsencrypt/live/your-domain.com/fullchain.pem" ]; then
    openssl x509 -enddate -noout -in /etc/letsencrypt/live/your-domain.com/fullchain.pem
else
    echo "No SSL certificate found"
fi

echo ""

# Check system updates
echo "📦 System Updates:"
apt list --upgradable 2>/dev/null | head -5

echo ""
echo "🎉 Health check complete!"