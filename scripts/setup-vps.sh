#!/bin/bash

# VPS Setup Script for Contabo Ubuntu Server
# Run this script on your VPS to set up the deployment environment

set -e

echo "🚀 Setting up Contabo VPS for NestJS deployment..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
echo "🔧 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add current user to docker group
echo "👤 Adding user to docker group..."
sudo usermod -aG docker $USER

# Install other useful tools
echo "🛠️ Installing additional tools..."
sudo apt install -y git nginx certbot python3-certbot-nginx fail2ban ufw htop

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p /opt/byteforce-test
sudo chown $USER:$USER /opt/byteforce-test

# Create production docker-compose file
echo "📝 Creating production docker-compose.yml..."
cat > /opt/byteforce-test/docker-compose.yml << EOF
version: '3.8'

services:
  app:
    image: ghcr.io/davechpn/byteforce-test:latest
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - app
    restart: unless-stopped
EOF

# Create nginx configuration
echo "🌐 Creating nginx configuration..."
cat > /opt/byteforce-test/nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    upstream app {
        server app:3000;
    }

    server {
        listen 80;
        server_name your-domain.com www.your-domain.com; # Replace with your domain

        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 301 https://\$server_name\$request_uri;
        }
    }

    server {
        listen 443 ssl http2;
        server_name your-domain.com www.your-domain.com; # Replace with your domain

        # SSL configuration (will be set up by certbot)
        ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem; # Replace with your domain
        ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem; # Replace with your domain

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        location / {
            proxy_pass http://app;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_cache_bypass \$http_upgrade;
        }
    }
}
EOF

# Set up basic firewall
echo "🔥 Setting up firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# Set up fail2ban
echo "🛡️ Setting up fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "✅ VPS setup complete!"
echo ""
echo "Next steps:"
echo "1. Update the domain name in /opt/byteforce-test/nginx.conf"
echo "2. Set up SSL with: sudo certbot --nginx -d your-domain.com -d www.your-domain.com"
echo "3. Configure GitHub secrets for deployment"
echo "4. Log out and log back in for docker group changes to take effect"
echo ""
echo "GitHub Secrets needed:"
echo "- VPS_HOST: Your VPS IP address"
echo "- VPS_USER: Your VPS username"
echo "- VPS_SSH_KEY: Your private SSH key content"