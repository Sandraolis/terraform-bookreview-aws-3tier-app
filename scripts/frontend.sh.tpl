#!/bin/bash

set -e

# Update & install dependencies
sudo apt update -y
sudo apt install -y nodejs npm nginx git

# Install PM2 globally
sudo npm install -g pm2

# Fix PATH issue
export PATH=$PATH:/usr/bin

# Switch to ubuntu user for app setup
cd /home/ubuntu

# Clone repo if not exists
if [ ! -d "book-review-app" ]; then
  git clone https://github.com/pravinmishraaws/book-review-app.git
fi

cd book-review-app/frontend

npm install
npm run build

pm2 start npm --name frontend -- start
pm2 save

# Setup PM2 startup
pm2 startup systemd -u ubuntu --hp /home/ubuntu

# Configure Nginx
sudo bash -c 'cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF'

sudo nginx -t
sudo systemctl restart nginx
