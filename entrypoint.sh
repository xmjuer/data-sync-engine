#!/bin/bash

# 定义路径
WORK_DIR="/usr/local/bin/sys-service"
TEMP_DIR="/var/opt/cache/temp"
DATA_DIR="/var/opt/cache/data"
CONF_DIR="/var/opt/cache/conf"

cd $WORK_DIR

# 1. 生成 Cloudreve 配置
echo "W1N5c3RlbV0KTW9kZSA9IG1hc3RlcgpMaXN0ZW4gPSA6Nzg2MAoKW0RhdGFiYXNlXQpUeXBlID0gc3FsaXRlCkRCRmlsZSA9IC92YXIvb3B0L2NhY2hlL2RhdGEvc3lzX2RiLmRiCg==" | base64 -d > conf.ini

# 2. 准备 Session 文件
touch $CONF_DIR/session.lock
chmod 666 $CONF_DIR/session.lock

# 3. 启动网络进程 (Aria2 -> net_worker) 并开启日志
echo "Starting Network Service (net_worker)..."
./net_worker \
  --enable-rpc \
  --rpc-listen-all \
  --rpc-allow-origin-all \
  --rpc-secret=sys_token_123 \
  --dir=$TEMP_DIR \
  --input-file=$CONF_DIR/session.lock \
  --save-session=$CONF_DIR/session.lock \
  --log-level=notice &

# 等待 3 秒
sleep 3

# 检查进程是否存活
if pgrep -x "net_worker" > /dev/null
then
    echo "SUCCESS: Network Service is running."
else
    echo "ERROR: Network Service failed to start! Check logs above for details."
fi

# 4. 启动主程序
echo "Initializing System Kernel..."
./sys_kernel
