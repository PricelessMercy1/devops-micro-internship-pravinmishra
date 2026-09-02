#!/bin/bash
set -e

exec > /var/log/cloud-init-deploy.log 2>&1
echo "=== Starting React app deployment ==="

# Add swap — B2ts_v2 only has ~1GB RAM, npm run build can need more
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

apt-get update -y
apt-get upgrade -y

# Node.js 18.x via NodeSource (apt's default nodejs on 22.04 is too old)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs nginx git

systemctl enable nginx
systemctl start nginx

cd /opt
git clone https://github.com/pravinmishraaws/my-react-app.git
cd my-react-app

# Personalize
sed -i 's/Your Full Name/Aanuoluwapo Tolu-Omodara/' src/App.js
sed -i "s#DD/MM/YYYY#$(date +%d/%m/%Y)#" src/App.js

npm install
npm run build

rm -rf /var/www/html/*
cp -r build/* /var/www/html/
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

cat > /etc/nginx/sites-available/default << 'NGINXCONF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html;
    location / {
        try_files $uri /index.html;
    }
    error_page 404 /index.html;
}
NGINXCONF

nginx -t
systemctl restart nginx

echo "=== React app deployment complete ==="