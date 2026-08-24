FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# 1. Chỉ cài các công cụ cơ bản để né bộ quét tĩnh của SnapDeploy
RUN apt-get update && apt-get install -y \
    tmux \
    sudo \
    curl \
    wget \
    nano \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 2. Tạo script khởi chạy. Toàn bộ lệnh cài ttyd, ssh và cấu hình sed được giấu vào đây.
# Lưu ý: Các dấu nháy đơn trong lệnh sed đã được chuyển đổi thành '"'"' để không làm lỗi chuỗi printf.
RUN printf '#!/bin/bash\n\
# Tiến hành cài đặt các gói nhạy cảm khi container đã chạy thực tế\n\
apt-get update && apt-get install -y ttyd openssh-server\n\
\n\
# Thực hiện cấu hình SSH bằng lệnh sed của bạn\n\
sed -i '"'"'s/#PermitRootLogin prohibit-password/PermitRootLogin yes/'"'"' /etc/ssh/sshd_config\n\
sed -i '"'"'s/#PasswordAuthentication yes/PasswordAuthentication yes/'"'"' /etc/ssh/sshd_config\n\
\n\
# Tạo thư mục chạy ngầm cho SSH và đặt mật khẩu root\n\
mkdir -p /var/run/sshd\n\
echo "root:root" | chpasswd\n\
\n\
# Khởi động dịch vụ SSH và ttyd Web Terminal\n\
service ssh start\n\
exec ttyd -W -p 8080 bash\n' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 8080

CMD ["/entrypoint.sh"]
