#!/bin/bash

# 定义伪装路径
WORK_DIR="/usr/local/bin/sys-service"
TEMP_DIR="/var/opt/cache/temp"
DATA_DIR="/var/opt/cache/data"

cd $WORK_DIR

# ----------------------------------------------------------------
# 1. 动态生成核心配置 (Base64 解密)
# 监听端口: 7860
# 数据库路径: /var/opt/cache/data/sys_db.db
# ----------------------------------------------------------------
# 下面这串 Base64 解码后是 Cloudreve 的标准配置，指定了数据库在可写目录
echo "W1N5c3RlbV0KTW9kZSA9IG1hc3RlcgpMaXN0ZW4gPSA6Nzg2MAoKW0RhdGFiYXNlXQpUeXBlID0gc3FsaXRlCkRCRmlsZSA9IC92YXIvb3B0L2NhY2hlL2RhdGEvc3lzX2RiLmRiCg==" | base64 -d > conf.ini

# ----------------------------------------------------------------
# 2. 初始化网络组件配置 (Session文件)
# ----------------------------------------------------------------
# 确保 conf 目录存在且可写
mkdir -p conf
touch conf/session.lock
chmod 666 conf/session.lock

# ----------------------------------------------------------------
# 3. 启动网络进程 (Aria2 -> net_worker)
# 伪装名: net_worker
# 密钥: sys_token_123
# 下载目录: /var/opt/cache/temp
# ----------------------------------------------------------------
echo "Starting Network Service..."
./net_worker \
  --enable-rpc \
  --rpc-listen-all \
  --rpc-allow-origin-all \
  --rpc-secret=sys_token_123 \
  --dir=$TEMP_DIR \
  --input-file=conf/session.lock \
  --save-session=conf/session.lock \
  --daemon

# 等待 2 秒确保 Aria2 启动完成
sleep 2

# ----------------------------------------------------------------
# 4. 启动主核心 (Cloudreve -> sys_kernel)
# ----------------------------------------------------------------
echo "Initializing System Kernel..."
./sys_kernel
