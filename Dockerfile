FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

ENV PORT=8080

# 1. Cập nhật hệ thống và cài đặt ttyd cùng các công cụ hỗ trợ cơ bản
RUN apt update && apt install -y \
    ttyd \
    tmux \
    openssh-server \
    sudo \
    curl \
    wget \
    nano \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'root:root' | chpasswd

# Khai báo mở cổng 8080 phục vụ cho Web Terminal
EXPOSE 8080

CMD ["ttyd", "-W", "-p", "8080", "bash"]
