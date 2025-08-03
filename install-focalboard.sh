#!/bin/bash

# Exit on any error
set -e

# Prompt user for input
echo "Please provide the following information for Focalboard installation:"
read -p "Enter your domain (e.g., focalboard.example.com): " DOMAIN
read -p "Enter your email for Let's Encrypt (e.g., your-email@example.com): " EMAIL
read -s -p "Enter a secure password for PostgreSQL user (boardsuser): " POSTGRES_PASSWORD
echo ""

# Validate input
if [[ -z "$DOMAIN" || -z "$EMAIL" || -z "$POSTGRES_PASSWORD" ]]; then
    echo "Error: All fields (domain, email, password) are required."
    exit 1
fi

# Variables
FOCALBOARD_DIR="/opt/focalboard"
POSTGRES_USER="boardsuser"
POSTGRES_DB="boards"

# Step 1: Update system and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget gnupg2 nginx postgresql postgresql-contrib certbot python3-certbot-nginx

# Step 2: Download and extract the latest Focalboard release
echo "Downloading and extracting the latest Focalboard release..."
VER=$(curl -s https://api.github.com/repos/mattermost/focalboard/releases/latest | grep tag_name | cut -d '"' -f 4)
wget -O /tmp/focalboard.tar.gz https://github.com/mattermost/focalboard/releases/download/${VER}/focalboard-server-linux-amd64.tar.gz
tar -xvzf /tmp/focalboard.tar.gz -C /tmp
sudo mv /tmp/focalboard $FOCALBOARD_DIR
rm /tmp/focalboard.tar.gz

# Step 3: Configure PostgreSQL
echo "Configuring PostgreSQL..."
sudo --login --user postgres psql -c "CREATE DATABASE $POSTGRES_DB;"
sudo --login --user postgres psql -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';"
sudo --login --user postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;"
sudo --login --user postgres psql -c "\q"

# Step 4: Configure Focalboard to use PostgreSQL
echo "Configuring Focalboard to use PostgreSQL..."
sudo sed -i "s/\"dbtype\": \".*\"/\"dbtype\": \"postgres\"/" $FOCALBOARD_DIR/config.json
sudo sed -i "s|\"dbconfig\": \".*\"|\"dbconfig\": \"postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost/$POSTGRES_DB?sslmode=disable&connect_timeout=10\"|" $FOCALBOARD_DIR/config.json

# Step 5: Configure NGINX
echo "Configuring NGINX..."
sudo rm -f /etc/nginx/sites-enabled/default
cat << EOF | sudo tee /etc/nginx/sites-available/focalboard
upstream focalboard {
   server localhost:8000;
   keepalive 32;
}

server {
   listen 80;
   server_name $DOMAIN;

   location ~ /ws/* {
       proxy_set_header Upgrade \$http_upgrade;
       proxy_set_header Connection "upgrade";
       client_max_body_size 50M;
       proxy_set_header Host \$http_host;
       proxy_set_header X-Real-IP \$remote_addr;
       proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto \$scheme;
       proxy_set_header X-Frame-Options SAMEORIGIN;
       proxy_buffers 256 16k;
       proxy_buffer_size 16k;
       client_body_timeout 60;
       send_timeout 300;
       lingering_timeout 5;
       proxy_connect_timeout 1d;
       proxy_send_timeout 1d;
       proxy_read_timeout 1d;
       proxy_pass http://focalboard;
   }

   location / {
       client_max_body_size 50M;
       proxy_set_header Connection "";
       proxy_set_header Host \$http_host;
       proxy_set_header X-Real-IP \$remote_addr;
       proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto \$scheme;
       proxy_set_header X-Frame-Options SAMEORIGIN;
       proxy_buffers 256 16k;
       proxy_buffer_size 16k;
       proxy_read_timeout 600s;
       proxy_cache_revalidate on;
       proxy_cache_min_uses 2;
       proxy_cache_use_stale timeout;
       proxy_cache_lock on;
       proxy_http_version 1.1;
       proxy_pass http://focalboard;
   }
}
EOF

sudo ln -s /etc/nginx/sites-available/focalboard /etc/nginx/sites-enabled/focalboard
sudo nginx -t
sudo systemctl reload nginx

# Step 6: Set up Let's Encrypt for TLS
echo "Setting up Let's Encrypt for TLS..."
sudo certbot --nginx --non-interactive --agree-tos --email "$EMAIL" -d "$DOMAIN" --redirect

# Step 7: Configure Focalboard as a systemd service
echo "Configuring Focalboard as a systemd service..."
cat << EOF | sudo tee /lib/systemd/system/focalboard.service
[Unit]
Description=Focalboard server

[Service]
Type=simple
Restart=always
RestartSec=5s
ExecStart=$FOCALBOARD_DIR/bin/focalboard-server
WorkingDirectory=$FOCALBOARD_DIR

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start focalboard.service
sudo systemctl enable focalboard.service

# Step 8: Test the server
echo "Testing the server..."
if curl -s localhost:8000 | grep -q "Focalboard"; then
    echo "Focalboard server is running on port 8000."
else
    echo "Failed to verify Focalboard server on port 8000."
    exit 1
fi

if curl -s localhost | grep -q "Focalboard"; then
    echo "NGINX is successfully proxying requests."
else
    echo "Failed to verify NGINX proxy."
    exit 1
fi

echo "Focalboard installation completed successfully! Access it at https://$DOMAIN"
