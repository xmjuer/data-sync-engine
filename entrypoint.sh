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
mkdir -p $CONF_DIR
touch $CONF_DIR/session.lock
chmod 666 $CONF_DIR/session.lock

# 3. 定义 Tracker 列表 (这是 Aria2 的"眼睛")
# 包含 http, https, udp 协议的全球热门 Tracker
TRACKERS="http://nyaa.tracker.wf:7777/announce,http://open.acgnxtracker.com:80/announce,http://share.camoe.cn:8080/announce,http://t.nyaatracker.com/announce,http://tracker.bt4g.com:2095/announce,http://tracker.files.fm:6969/announce,http://tracker.gbitt.info:80/announce,http://tracker.noobsubs.net:80/announce,http://tracker.nyap2p.com:8080/announce,http://tracker.opentrackr.org:1337/announce,udp://open.stealth.si:80/announce,udp://opentracker.i2p.rocks:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://tracker.moeking.me:6969/announce,udp://tracker.opentrackr.org:1337/announce,udp://tracker.tiny-vps.com:6969/announce,udp://tracker.torrent.eu.org:451/announce,udp://wambo.club:1337/announce,udp://tracker.doko.moe:6969/announce,udp://tracker.zerobytes.xyz:1337/announce"

# 4. 启动网络进程 (Aria2 -> net_worker)
# 【核心升级】：加入了 dht, pex, encryption 和内置 tracker
echo "Starting Network Service (net_worker)..."
./net_worker \
  --enable-rpc \
  --rpc-listen-all \
  --rpc-allow-origin-all \
  --rpc-secret=sys_token_123 \
  --dir=$TEMP_DIR \
  --input-file=$CONF_DIR/session.lock \
  --save-session=$CONF_DIR/session.lock \
  --log-level=notice \
  --enable-dht=true \
  --dht-listen-port=6881-6999 \
  --bt-enable-lpd=true \
  --enable-peer-exchange=true \
  --bt-min-crypto-level=arc4 \
  --bt-require-crypto=false \
  --peer-id-prefix=-TR2770- \
  --user-agent=Transmission/2.77 \
  --bt-tracker=$TRACKERS \
  &

# 等待启动
sleep 5

# 检查进程
if pgrep -x "net_worker" > /dev/null
then
    echo "SUCCESS: Network Service is running with Enhanced Config."
else
    echo "ERROR: Network Service failed to start! Check logs."
fi

# 5. 启动主程序
echo "Initializing System Kernel..."
./sys_kernel
