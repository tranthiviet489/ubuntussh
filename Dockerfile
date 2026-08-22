FROM ubuntu:latest

# Tránh các câu hỏi tương tác hiện lên gây lỗi khi build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Cập nhật hệ thống và cài đặt các công cụ bạn yêu cầu
RUN apt update && apt install openssh-server sudo curl wget nano unzip -y

# 2. Tải về, giải nén và phân quyền cho LocalXpose
RUN wget https://localxpose.io \
    && unzip loclx-linux-amd64.zip \
    && mv loclx /usr/local/bin/ \
    && chmod +x /usr/local/bin/loclx \
    && rm loclx-linux-amd64.zip

# 3. Đăng nhập và lưu Token LocalXpose của bạn
RUN loclx tunnel account login --token TSnH7rrlEyGKZLX1LbV2L6NF1Ws0lEnUMyLUkumJ

# 4. Sửa cấu hình /etc/ssh/sshd_config (Bỏ dấu #, bật PasswordAuth và cho phép đăng nhập Root)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && mkdir /var/run/sshd

# 5. Đặt mật khẩu cho tài khoản root để bạn SSH từ xa (Hãy đổi "Mật_Khẩu_Của_Bạn" thành mật khẩu tùy ý)
RUN echo 'root:root' | chpasswd

# Mở port 22 nội bộ trong container
EXPOSE 22

# 6. Lệnh gộp trực tiếp vào Dockerfile: Bật dịch vụ SSH và chạy ngay TCP Tunnel
CMD service ssh start && loclx tunnel tcp --to 127.0.0.1:22
