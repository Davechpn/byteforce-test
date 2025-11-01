# NestJS Application Deployment Guide

This guide will help you deploy your NestJS application to a Contabo VPS using Docker and GitHub Actions.

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd byteforce-test
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run the application**
   ```bash
   npm run start:dev
   ```

4. **Test with Docker locally**
   ```bash
   docker-compose up --build
   ```

## 🏗️ Production Deployment

### Step 1: Set Up Your Contabo VPS

1. **Connect to your VPS**
   ```bash
   ssh your-username@your-vps-ip
   ```

2. **Run the setup script**
   ```bash
   wget https://raw.githubusercontent.com/Davechpn/byteforce-test/main/scripts/setup-vps.sh
   chmod +x setup-vps.sh
   ./setup-vps.sh
   ```

3. **Configure your domain** (Replace `your-domain.com` with your actual domain)
   ```bash
   sudo nano /opt/byteforce-test/nginx.conf
   # Update all instances of "your-domain.com" with your actual domain
   ```

4. **Set up SSL certificate**
   ```bash
   sudo certbot --nginx -d your-domain.com -d www.your-domain.com
   ```

### Step 2: Configure GitHub Secrets

In your GitHub repository, go to Settings → Secrets and variables → Actions, and add:

- `VPS_HOST`: Your VPS IP address
- `VPS_USER`: Your VPS username (usually root or your user)
- `VPS_SSH_KEY`: Your private SSH key content

### Step 3: Deploy

Push to the `main` branch to trigger automatic deployment:

```bash
git add .
git commit -m "Initial deployment setup"
git push origin main
```

## 🛠️ Manual Deployment

If you need to deploy manually:

```bash
# On your VPS
cd /opt/byteforce-test
./scripts/deploy.sh
```

## 📊 Monitoring

### Check Application Health

```bash
# On your VPS
cd /opt/byteforce-test
./scripts/health-check.sh
```

### View Logs

```bash
# Application logs
docker-compose logs -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Container Management

```bash
# Stop containers
docker-compose down

# Start containers
docker-compose up -d

# Restart containers
docker-compose restart

# Check container status
docker-compose ps
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

### Docker Configuration

- **Dockerfile**: Multi-stage build for optimized production image
- **docker-compose.yml**: Local development setup
- **.dockerignore**: Excludes unnecessary files from Docker context

### CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) automatically:

1. Runs tests
2. Builds Docker image
3. Pushes to GitHub Container Registry
4. Deploys to your VPS

## 🔒 Security Features

- Non-root user in Docker container
- Basic firewall configuration with UFW
- Fail2ban for intrusion prevention
- SSL/TLS encryption with Let's Encrypt
- Security headers in Nginx
- Container health checks

## 🚨 Troubleshooting

### Common Issues

1. **Container won't start**
   ```bash
   docker-compose logs
   ```

2. **SSL certificate issues**
   ```bash
   sudo certbot renew --dry-run
   ```

3. **Nginx configuration errors**
   ```bash
   sudo nginx -t
   ```

4. **Port conflicts**
   ```bash
   sudo netstat -tulpn | grep :80
   sudo netstat -tulpn | grep :443
   ```

### Logs Location

- Application: `docker-compose logs`
- Nginx: `/var/log/nginx/`
- System: `/var/log/syslog`

## 📈 Performance Optimization

### For High Traffic

1. **Enable Nginx caching**
2. **Add Redis for session storage**
3. **Implement horizontal scaling with Docker Swarm**
4. **Set up a CDN**

### Monitoring Tools

Consider adding:
- Prometheus + Grafana for metrics
- ELK stack for log analysis
- Uptime monitoring services

## 🔄 Updates and Maintenance

### Automatic Updates

The CI/CD pipeline handles updates automatically when you push to the main branch.

### Manual Updates

```bash
# On your VPS
cd /opt/byteforce-test
docker-compose pull
docker-compose up -d
docker image prune -f
```

### System Maintenance

```bash
# Update system packages
sudo apt update && sudo apt upgrade

# Renew SSL certificates
sudo certbot renew

# Clean up Docker
docker system prune -f
```

## 📝 Support

For issues or questions:
1. Check the logs first
2. Review this documentation
3. Check GitHub Issues
4. Contact the development team

## 🎯 Next Steps

Consider implementing:
- Database integration (PostgreSQL/MongoDB)
- Redis for caching
- Monitoring and alerting
- Backup strategies
- Load balancing for multiple instances