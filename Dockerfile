FROM ubuntu:latest

# Tránh các câu hỏi tương tác hiện lên gây lỗi khi build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Cập nhật hệ thống và cài đặt các công cụ cần thiết
RUN apt update && apt install openssh-server sudo curl wget nano unzip -y

# 2. Tải về, giải nén và cài đặt LocalXpose
RUN wget https://api.localxpose.io/api/downloads/loclx-linux-amd64.deb \
    && dpkg -i loclx-linux-amd64.deb \
    && rm loclx-linux-amd64.deb

# 3. Cấu hình biến môi trường chứa Access Token (Thay thế hoàn toàn bước đăng nhập cũ)
ENV LOCALXPOSE_ACCESS_TOKEN="TSnH7rrlEyGKZLX1LbV2L6NF1Ws0lEnUMyLUkumJ"

# 4. Sửa cấu hình /etc/ssh/sshd_config (Bật PasswordAuth và cho phép đăng nhập Root)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && mkdir /var/run/sshd

# 5. Đặt mật khẩu cho tài khoản root (Mặc định đang là root:root)
RUN echo 'root:root' | chpasswd

# Mở port 22 nội bộ trong container
EXPOSE 22

# 6. Khởi động dịch vụ SSH và chạy TCP Tunnel bằng cơ chế ngầm (sử dụng --raw-mode để tránh lỗi UI log trong container)
CMD service ssh start && loclx tunnel tcp --to 127.0.0.1:22 --raw-mode
