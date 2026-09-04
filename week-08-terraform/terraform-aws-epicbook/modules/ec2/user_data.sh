#!/bin/bash
# EpicBook EC2 bootstrap script
# Installs required software only. No database credentials or secrets here.
set -e

exec > /var/log/user-data.log 2>&1
echo "===== EpicBook user_data started: $(date) ====="

export DEBIAN_FRONTEND=noninteractive

# 1. Base packages
apt-get update -y
apt-get install -y git curl build-essential nginx mysql-client

# 2. Node.js 18.x (NodeSource)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# 3. PM2 for process management (used later when starting the app)
npm install -g pm2

# 4. Clone the EpicBook application (public repo, no credentials required)
cd /home/ubuntu
git clone https://github.com/pravinmishraaws/theepicbook.git
cd theepicbook
npm install
chown -R ubuntu:ubuntu /home/ubuntu/theepicbook

# 5. Configure Nginx as a reverse proxy: 80 -> 8080 (EpicBook app port)
cat > /etc/nginx/sites-available/epicbook <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/epicbook /etc/nginx/sites-enabled/epicbook
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl restart nginx

echo "===== EpicBook user_data finished: $(date) ====="