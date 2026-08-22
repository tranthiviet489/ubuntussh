FROM ubuntu:latest

# Tránh các câu hỏi tương tác hiện lên gây lỗi khi build
ENV DEBIAN_FRONTEND=noninteractive

# Định nghĩa cổng chính cho Back4App nhận diện để Health Check (Cực kỳ quan trọng)
ENV PORT=22

# 1. Cập nhật hệ thống và cài đặt các công cụ cần thiết
RUN apt update && apt install openssh-server sudo curl wget nano unzip -y

# 2. Tải về và cài đặt LocalXpose
RUN wget https://api.localxpose.io/api/downloads/loclx-linux-amd64.deb \
    && dpkg -i loclx-linux-amd64.deb \
    && rm loclx-linux-amd64.deb

# 3. Cấu hình biến môi trường chứa Access Token
ENV LOCALXPOSE_ACCESS_TOKEN="TSnH7rrlEyGKZLX1LbV2L6NF1Ws0lEnUMyLUkumJ"

# 4. Sửa cấu hình SSH (Cho phép đăng nhập Root và mật khẩu)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd

# 5. Đặt mật khẩu cho tài khoản root (Mặc định là root:root)
RUN echo 'root:root' | chpasswd

# Mở port 22 nội bộ trong container
EXPOSE 22

# 6. Khởi động dịch vụ SSH và chạy TCP Tunnel (Đã loại bỏ flag lỗi và tối ưu cấu trúc lệnh)
CMD service ssh start && loclx tunnel tcp --to 127.0.0.1:22
