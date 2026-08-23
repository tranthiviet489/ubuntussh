FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8080

# 1. Cập nhật hệ thống và cài đặt các công cụ cần thiết
RUN apt-get update && apt-get install -y \
    ttyd \
    tmux \
    openssh-server \
    sudo \
    curl \
    wget \
    nano \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 2. Tải và cài đặt Cloudflared phiên bản mới nhất cho amd64
RUN wget https://github.com/cloudflare/cloudflared/releases/download/2026.7.3/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared-linux-amd64.deb && \
    rm cloudflared-linux-amd64.deb

# 3. Đặt mật khẩu cho tài khoản root
RUN echo 'root:root' | chpasswd

# 4. Tạo file script khởi chạy cả 2 tiến trình cùng lúc
RUN printf '#!/bin/bash\n\
# Khởi chạy Cloudflare Tunnel ở chế độ chạy ngầm\n\
cloudflared tunnel --url http://localhost:8080 &\n\
\n\
# Khởi chạy ttyd làm tiến trình chính để giữ container luôn chạy\n\
exec ttyd -W -p 8080 bash\n' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8080

# Gọi script khi container khởi động
CMD ["/entrypoint.sh"]
