#!/bin/bash
cat << 'EOF' > frpc.toml
serverAddr = "vpsubuntu.us.frps.uk"
serverPort = 7000
auth.token = "TokenChinhXacCuaBan"

[[proxies]]
name = "ssh_vpsubuntu"             
type = "tcp"
localIP = "127.0.0.1"
localPort = 22                     
remotePort = 22026             
EOF
