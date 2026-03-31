#!/bin/bash
set -e

sudo apt update -y
sudo apt install -y nodejs npm git mysql-client

sudo npm install -g pm2
export PATH=$PATH:/usr/bin

cd /home/ubuntu

if [ ! -d "book-review-app" ]; then
  git clone https://github.com/pravinmishraaws/book-review-app.git
fi

cd book-review-app/backend

npm install

# Create .env file
cat <<EOF > .env
DB_HOST=${db_host}
DB_USER=admin
DB_PASS=${db_pass}
DB_NAME=bookreview
PORT=3001
EOF

# Wait for DB
until mysql -h ${db_host} -u admin -p${db_pass} -e "SELECT 1"; do
  sleep 5
done

pm2 start src/server.js --name backend
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu
