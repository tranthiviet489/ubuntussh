FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

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

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && mkdir -p /var/run/sshd

# 3. Đặt mật khẩu cho tài khoản root
RUN echo 'root:root' | chpasswd

RUN printf '#!/bin/bash\n\
# Khởi động dịch vụ SSH chạy ngầm\n\
exec service ssh start\n\
# Khởi chạy ttyd làm tiến trình chính để giữ container luôn chạy\n\
exec ttyd -W -p 8080 bash\n' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 8080

# Gọi script khi container khởi động
CMD ["/entrypoint.sh"]
