# Focalboard Installation Guide

This repository contains a bash script (`install-focalboard.sh`) to automate the installation of [Focalboard Personal Server](https://www.focalboard.com/) on an Ubuntu server. The script sets up Focalboard with NGINX, PostgreSQL, and Let's Encrypt for SSL, enabling you to run Focalboard with a single command.

## Prerequisites

Before running the script, ensure the following:
- You are using **Ubuntu 18.04 or later**.
- You have **root or sudo privileges**.
- Your server has a **public IP address** and a **domain name** properly configured to point to the server's IP (required for Let's Encrypt SSL).
- You have **internet access** to download dependencies and the Focalboard release.

## Installation Steps

1. **Clone or Download the Script**  
   Clone this repository or download the `install-focalboard.sh` script directly:
   ```bash
   wget https://raw.githubusercontent.com/vsisnet/Focalboard/main/install-focalboard.sh
   ```

2. **Make the Script Executable**  
   Grant execute permissions to the script:
   ```bash
   chmod +x install-focalboard.sh
   ```

3. **Run the Script**  
   Execute the script with sudo privileges:
   ```bash
   sudo ./install-focalboard.sh
   ```

4. **Provide Required Information**  
   During execution, the script will prompt you to enter:
   - **Domain**: Your domain name (e.g., `focalboard.example.com`).
   - **Email**: Your email address for Let's Encrypt SSL certificate notifications.
   - **PostgreSQL Password**: A secure password for the PostgreSQL `boardsuser` account.

5. **Access Focalboard**  
   Once the installation is complete, access Focalboard via your browser at `https://<your-domain>`.

## What the Script Does

The `install-focalboard.sh` script automates the following:
- Updates the system and installs dependencies (curl, wget, NGINX, PostgreSQL, Certbot).
- Downloads and extracts the latest Focalboard release from GitHub.
- Configures PostgreSQL with a dedicated database and user.
- Sets up NGINX as a reverse proxy with optimized settings.
- Configures Let's Encrypt for SSL to secure web traffic.
- Runs Focalboard as a systemd service for automatic restarts.
- Tests the server to ensure it is running correctly.

## Troubleshooting

- **Check Service Status**: Verify that Focalboard is running:
  ```bash
  sudo systemctl status focalboard.service
  ```
- **Check Logs**: If issues arise, inspect the logs:
  - NGINX: `/var/log/nginx/error.log`
  - Focalboard: `/opt/focalboard/focalboard.log`
- **Firewall**: Ensure ports 80 and 443 are open for HTTP and HTTPS traffic.
- **Domain Issues**: Confirm your domain's DNS records point to your server's IP.

## Notes

- The script uses **PostgreSQL** as the database, as recommended for production environments.
- Ensure your domain is correctly configured before running the script to avoid Let's Encrypt failures.
- For MySQL support or additional customizations, modify the script or contact the repository maintainer.

## License

This script is provided under the MIT License. See [LICENSE](LICENSE) for details.

---

# Hướng Dẫn Cài Đặt Focalboard

Kho lưu trữ này chứa một script bash (`install-focalboard.sh`) để tự động hóa việc cài đặt [Focalboard Personal Server](https://www.focalboard.com/) trên máy chủ Ubuntu. Script này thiết lập Focalboard với NGINX, PostgreSQL và Let's Encrypt để bảo mật SSL, cho phép bạn cài đặt Focalboard chỉ bằng một lệnh duy nhất.

## Yêu Cầu Cần Thiết

Trước khi chạy script, hãy đảm bảo:
- Bạn đang sử dụng **Ubuntu 18.04 hoặc mới hơn**.
- Bạn có **quyền root hoặc sudo**.
- Máy chủ của bạn có **địa chỉ IP công cộng** và **tên miền** được cấu hình chính xác để trỏ đến IP của máy chủ (yêu cầu cho Let's Encrypt SSL).
- Máy chủ có **kết nối internet** để tải các phụ thuộc và bản phát hành Focalboard.

## Các Bước Cài Đặt

1. **Tải Script**  
   Sao chép kho lưu trữ này hoặc tải trực tiếp script `install-focalboard.sh`:
   ```bash
   wget https://raw.githubusercontent.com/vsisnet/Focalboard/main/install-focalboard.sh
   ```

2. **Cấp Quyền Thực Thi**  
   Cấp quyền thực thi cho script:
   ```bash
   chmod +x install-focalboard.sh
   ```

3. **Chạy Script**  
   Thực thi script với quyền sudo:
   ```bash
   sudo ./install-focalboard.sh
   ```

4. **Cung Cấp Thông Tin Yêu Cầu**  
   Trong quá trình chạy, script sẽ yêu cầu bạn nhập:
   - **Tên miền**: Tên miền của bạn (ví dụ: `focalboard.example.com`).
   - **Email**: Địa chỉ email để nhận thông báo chứng chỉ SSL từ Let's Encrypt.
   - **Mật khẩu PostgreSQL**: Mật khẩu an toàn cho tài khoản `boardsuser` của PostgreSQL.

5. **Truy Cập Focalboard**  
   Sau khi cài đặt hoàn tất, truy cập Focalboard qua trình duyệt tại `https://<tên-miền-của-bạn>`.

## Script Thực Hiện Những Gì

Script `install-focalboard.sh` tự động thực hiện các bước sau:
- Cập nhật hệ thống và cài đặt các phụ thuộc (curl, wget, NGINX, PostgreSQL, Certbot).
- Tải và giải nén phiên bản mới nhất của Focalboard từ GitHub.
- Cấu hình PostgreSQL với cơ sở dữ liệu và người dùng chuyên dụng.
- Thiết lập NGINX làm proxy ngược với các cài đặt tối ưu.
- Cấu hình Let's Encrypt để bảo mật lưu lượng web bằng SSL.
- Chạy Focalboard dưới dạng dịch vụ systemd để tự động khởi động lại.
- Kiểm tra máy chủ để đảm bảo hoạt động đúng.

## Khắc Phục Sự Cố

- **Kiểm Tra Trạng Thái Dịch Vụ**: Xác minh Focalboard đang chạy:
  ```bash
  sudo systemctl status focalboard.service
  ```
- **Kiểm Tra Log**: Nếu gặp sự cố, kiểm tra log:
  - NGINX: `/var/log/nginx/error.log`
  - Focalboard: `/opt/focalboard/focalboard.log`
- **Tường Lửa**: Đảm bảo các cổng 80 và 443 mở cho lưu lượng HTTP và HTTPS.
- **Vấn Đề Tên Miền**: Xác nhận bản ghi DNS của tên miền trỏ đúng đến IP của máy chủ.

## Lưu Ý

- Script sử dụng **PostgreSQL** làm cơ sở dữ liệu, theo khuyến nghị cho môi trường sản xuất.
- Đảm bảo tên miền được cấu hình chính xác trước khi chạy script để tránh lỗi Let's Encrypt.
- Để hỗ trợ MySQL hoặc tùy chỉnh thêm, hãy sửa đổi script hoặc liên hệ với người duy trì kho lưu trữ.

## Giấy Phép

Script này được cung cấp theo Giấy phép MIT. Xem [LICENSE](LICENSE) để biết chi tiết.