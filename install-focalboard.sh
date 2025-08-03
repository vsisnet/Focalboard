#!/bin/bash

set -e

echo "📥 Đang cập nhật hệ thống và cài đặt các gói phụ thuộc..."
sudo apt update && sudo apt install -y wget tar

echo "⬇️ Tải Focalboard Personal Edition mới nhất..."
wget https://downloads.focalboard.com/focalboard-0.9.0-linux.tar.gz -O /tmp/focalboard.tar.gz

echo "📦 Giải nén Focalboard..."
sudo mkdir -p /opt/focalboard
sudo tar -xvzf /tmp/focalboard.tar.gz -C /opt/focalboard

echo "⚙️ Tạo file cấu hình dịch vụ systemd..."
sudo tee /etc/systemd/system/focalboard.service > /dev/null <<EOF
[Unit]
Description=Focalboard Personal Server
After=network.target

[Service]
Type=simple
Restart=always
WorkingDirectory=/opt/focalboard
ExecStart=/opt/focalboard/bin/focalboard-server
User=www-data
Group=www-data

[Install]
WantedBy=multi-user.target
EOF

echo "🔐 Phân quyền thư mục cho user www-data..."
sudo chown -R www-data:www-data /opt/focalboard

echo "🚀 Khởi động và kích hoạt dịch vụ focalboard..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now focalboard

echo "✅ Focalboard đã được cài đặt và chạy tại http://localhost:8000"
