# Deployment Guide - Hetzner Server

This guide will walk you through deploying the Votenam Admin Panel Flutter web application on a Hetzner server.

## 📋 Prerequisites

- A Hetzner server (Cloud or Dedicated)
- Root or sudo access to the server
- A domain name pointing to your server's IP address (optional but recommended)
- SSH access to your server
- Flutter SDK installed locally (for building)

## 🚀 Deployment Methods

### Method 1: Build Locally and Deploy (Recommended)

This method builds the app on your local machine and transfers the built files to the server.

### Method 2: Build on Server

This method installs Flutter on the server and builds there.

---

## Method 1: Build Locally and Deploy

### Step 1: Build the Flutter Web App

On your local machine:

```bash
# Navigate to project directory
cd votenamadmin_flutter

# Get dependencies
flutter pub get

# Build for web
flutter build web --release
```

The built files will be in `build/web/` directory.

### Step 2: Prepare Deployment Package

Create a deployment package:

```bash
# Create a tarball of the built files
cd build
tar -czf votenamadmin-web.tar.gz web/
```

### Step 3: Transfer Files to Server

```bash
# Transfer to server (replace with your server details)
scp votenamadmin-web.tar.gz root@your-server-ip:/tmp/

# Or use SFTP client like FileZilla, WinSCP, etc.
```

### Step 4: Connect to Your Server

```bash
ssh root@your-server-ip
```

### Step 5: Install Nginx

```bash
# Update package list
apt update

# Install Nginx
apt install nginx -y

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Check status
systemctl status nginx
```

### Step 6: Extract and Deploy Files

```bash
# Create web directory
mkdir -p /var/www/votenamadmin

# Extract files
cd /tmp
tar -xzf votenamadmin-web.tar.gz
cp -r web/* /var/www/votenamadmin/

# Set proper permissions
chown -R www-data:www-data /var/www/votenamadmin
chmod -R 755 /var/www/votenamadmin
```

### Step 7: Configure Nginx

Create Nginx configuration file:

```bash
nano /etc/nginx/sites-available/votenamadmin
```

Add the following configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # If no domain, use server IP
    # server_name _;

    root /var/www/votenamadmin;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Handle Flutter web app routing (SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

Save and exit (Ctrl+X, then Y, then Enter).

### Step 8: Enable the Site

```bash
# Create symbolic link
ln -s /etc/nginx/sites-available/votenamadmin /etc/nginx/sites-enabled/

# Remove default site (optional)
rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

### Step 9: Configure Firewall

```bash
# Install UFW if not already installed
apt install ufw -y

# Allow SSH (important!)
ufw allow 22/tcp

# Allow HTTP
ufw allow 80/tcp

# Allow HTTPS
ufw allow 443/tcp

# Enable firewall
ufw enable

# Check status
ufw status
```

### Step 10: Set Up SSL with Let's Encrypt (Recommended)

```bash
# Install Certbot
apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
certbot --nginx -d your-domain.com -d www.your-domain.com

# Follow the prompts:
# - Enter your email
# - Agree to terms
# - Choose whether to redirect HTTP to HTTPS (recommended: Yes)

# Test automatic renewal
certbot renew --dry-run

# Certbot will automatically update your Nginx config
```

Your site should now be accessible at `https://your-domain.com`

---

## Method 2: Build on Server

### Step 1: Connect to Server

```bash
ssh root@your-server-ip
```

### Step 2: Install Required Dependencies

```bash
# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y curl git unzip xz-utils zip libglu1-mesa

# Install Flutter dependencies
apt install -y libstdc++6 libgcc1
```

### Step 3: Install Flutter on Server

```bash
# Download Flutter
cd /opt
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter doctor
```

### Step 4: Clone Your Repository

```bash
# Create app directory
mkdir -p /opt/apps
cd /opt/apps

# Clone your repository
git clone <your-repository-url> votenamadmin_flutter
cd votenamadmin_flutter
```

### Step 5: Build the App

```bash
# Get dependencies
flutter pub get

# Build for web
flutter build web --release
```

### Step 6: Deploy Built Files

```bash
# Create web directory
mkdir -p /var/www/votenamadmin

# Copy built files
cp -r build/web/* /var/www/votenamadmin/

# Set permissions
chown -R www-data:www-data /var/www/votenamadmin
chmod -R 755 /var/www/votenamadmin
```

### Step 7: Configure Nginx

Follow **Step 7** and **Step 8** from Method 1.

### Step 8: Set Up SSL and Firewall

Follow **Step 9** and **Step 10** from Method 1.

---

## 🔄 Updating the Application

### For Method 1 (Build Locally):

```bash
# On local machine
cd votenamadmin_flutter
flutter build web --release
cd build
tar -czf votenamadmin-web.tar.gz web/

# Transfer to server
scp votenamadmin-web.tar.gz root@your-server-ip:/tmp/

# On server
ssh root@your-server-ip
cd /tmp
tar -xzf votenamadmin-web.tar.gz
rm -rf /var/www/votenamadmin/*
cp -r web/* /var/www/votenamadmin/
chown -R www-data:www-data /var/www/votenamadmin
systemctl reload nginx
```

### For Method 2 (Build on Server):

```bash
# On server
cd /opt/apps/votenamadmin_flutter
git pull
flutter pub get
flutter build web --release
rm -rf /var/www/votenamadmin/*
cp -r build/web/* /var/www/votenamadmin/
chown -R www-data:www-data /var/www/votenamadmin
systemctl reload nginx
```

---

## 🛠️ Additional Configuration

### Set Up Auto-Deployment Script

Create a deployment script for easier updates:

```bash
nano /usr/local/bin/deploy-votenamadmin.sh
```

Add:

```bash
#!/bin/bash

APP_DIR="/opt/apps/votenamadmin_flutter"
WEB_DIR="/var/www/votenamadmin"

cd $APP_DIR
git pull
flutter pub get
flutter build web --release

rm -rf $WEB_DIR/*
cp -r build/web/* $WEB_DIR/
chown -R www-data:www-data $WEB_DIR
systemctl reload nginx

echo "Deployment completed!"
```

Make it executable:

```bash
chmod +x /usr/local/bin/deploy-votenamadmin.sh
```

Run with:

```bash
/usr/local/bin/deploy-votenamadmin.sh
```

### Set Up Cron Job for Auto-Updates (Optional)

```bash
# Edit crontab
crontab -e

# Add line to update daily at 2 AM (example)
0 2 * * * /usr/local/bin/deploy-votenamadmin.sh >> /var/log/votenamadmin-deploy.log 2>&1
```

### Monitor Application

```bash
# Check Nginx status
systemctl status nginx

# View Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# Check disk space
df -h

# Check memory usage
free -h
```

---

## 🔒 Security Best Practices

### 1. Firewall Configuration

```bash
# Only allow necessary ports
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable
```

### 2. SSH Hardening

```bash
# Edit SSH config
nano /etc/ssh/sshd_config

# Recommended settings:
# PermitRootLogin no
# PasswordAuthentication no (use SSH keys)
# Port 2222 (change default port)

# Restart SSH
systemctl restart sshd
```

### 3. Regular Updates

```bash
# Update system regularly
apt update && apt upgrade -y
```

### 4. Fail2Ban (Optional)

```bash
# Install Fail2Ban
apt install fail2ban -y

# Start and enable
systemctl start fail2ban
systemctl enable fail2ban
```

---

## 🐛 Troubleshooting

### Issue: Nginx won't start

```bash
# Check configuration
nginx -t

# Check logs
tail -f /var/log/nginx/error.log

# Check if port is in use
netstat -tulpn | grep :80
```

### Issue: 502 Bad Gateway

- Check if Nginx is running: `systemctl status nginx`
- Check file permissions: `ls -la /var/www/votenamadmin`
- Check Nginx error logs: `tail -f /var/log/nginx/error.log`

### Issue: Files not updating

```bash
# Clear browser cache
# Or hard refresh: Ctrl+Shift+R (Chrome/Firefox)

# Check file permissions
chown -R www-data:www-data /var/www/votenamadmin
chmod -R 755 /var/www/votenamadmin
```

### Issue: SSL Certificate Issues

```bash
# Renew certificate manually
certbot renew

# Check certificate status
certbot certificates
```

### Issue: Flutter build fails on server

- Ensure all dependencies are installed
- Check Flutter version: `flutter --version`
- Run `flutter doctor` to check for issues
- Consider using Method 1 (build locally) instead

---

## 📊 Performance Optimization

### 1. Enable Nginx Caching

Add to Nginx config:

```nginx
# Cache configuration
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=10g inactive=60m use_temp_path=off;

server {
    # ... existing config ...
    
    location / {
        proxy_cache my_cache;
        proxy_cache_valid 200 60m;
        try_files $uri $uri/ /index.html;
    }
}
```

### 2. Enable HTTP/2

In Nginx config (requires SSL):

```nginx
listen 443 ssl http2;
```

### 3. Compress Files

Already included in the Nginx config above.

---

## 🌐 Domain Configuration

### 1. Point Domain to Server

In your domain's DNS settings, add an A record:

```
Type: A
Name: @ (or your subdomain)
Value: your-server-ip
TTL: 3600
```

### 2. Wait for DNS Propagation

DNS changes can take up to 48 hours, but usually propagate within a few minutes to hours.

Check propagation:

```bash
# On server or local machine
dig your-domain.com
nslookup your-domain.com
```

---

## 📝 Quick Reference Commands

```bash
# Nginx
systemctl status nginx
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl reload nginx
nginx -t

# SSL
certbot renew
certbot certificates

# Firewall
ufw status
ufw enable
ufw disable

# Logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# File permissions
chown -R www-data:www-data /var/www/votenamadmin
chmod -R 755 /var/www/votenamadmin
```

---

## 🎯 Summary

After completing this guide, you should have:

✅ Flutter web app built and deployed  
✅ Nginx web server configured  
✅ SSL certificate installed (if using domain)  
✅ Firewall configured  
✅ Application accessible via HTTP/HTTPS  

Your application will be accessible at:
- `http://your-server-ip` (if no domain)
- `https://your-domain.com` (if domain configured)

---

## 📞 Support

If you encounter issues:

1. Check Nginx logs: `/var/log/nginx/error.log`
2. Verify file permissions
3. Test Nginx configuration: `nginx -t`
4. Check firewall rules: `ufw status`
5. Verify DNS settings (if using domain)

---

**Last Updated:** 2024

