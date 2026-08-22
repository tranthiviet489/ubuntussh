FROM ubuntu:latest

# Tránh các câu hỏi tương tác hiện lên gây lỗi khi build
ENV DEBIAN_FRONTEND=noninteractive

# Định nghĩa cổng 8080 cho Back4App nhận diện để vượt qua Health Check HTTP
ENV PORT=8080

# 1. Cập nhật hệ thống và cài đặt SSH Server cùng Python3
RUN apt update && apt install openssh-server sudo curl wget nano unzip python3 -y

# 2. Tải về và cài đặt LocalXpose
RUN wget https://api.localxpose.io/api/downloads/loclx-linux-amd64.deb \
    && dpkg -i loclx-linux-amd64.deb \
    && rm loclx-linux-amd64.deb

# 3. Cấu hình biến môi trường Token chuẩn mới nhất của LocalXpose
ENV LX_ACCESS_TOKEN="TSnH7rrlEyGKZLX1LbV2L6NF1Ws0lEnUMyLUkumJ"

# 4. Sửa cấu hình SSH (Cho phép đăng nhập bằng tài khoản root và mật khẩu công khai)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && mkdir -p /var/run/sshd

# 5. Đặt mật khẩu cho tài khoản root (Mặc định là root:root)
RUN echo 'root:root' | chpasswd

# Khai báo mở cổng nội bộ phục vụ cho việc vận hành
EXPOSE 22 8080

# 6. Khởi chạy đồng thời: Dịch vụ SSH, Web mồi 8080 để bypass Health Check, và mở TCP Tunnel cổng 22
CMD service ssh start && \
    python3 -m http.server 8080 --bind 0.0.0.0 & \
    sleep 2 && \
    loclx tunnel tcp --to 127.0.0.1:22
