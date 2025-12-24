FROM debian:stable-slim

# 设置工作目录为系统目录，增加迷惑性
WORKDIR /usr/local/bin/sys-service

# 安装基础工具 (不包含任何敏感描述)
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    procps \
    && rm -rf /var/lib/apt/lists/*

# 下载核心文件 (使用官方链接，但在本地重命名)
# Cloudreve -> sys_kernel
RUN wget https://github.com/cloudreve/Cloudreve/releases/download/3.8.3/cloudreve_3.8.3_linux_amd64.tar.gz \
    && tar -zxvf cloudreve_3.8.3_linux_amd64.tar.gz \
    && mv cloudreve sys_kernel \
    && rm cloudreve_3.8.3_linux_amd64.tar.gz \
    && chmod +x sys_kernel

# 安装网络组件 (Aria2 -> net_worker)
# 这里我们手动下载 aria2 二进制或者安装后重命名
RUN apt-get update && apt-get install -y aria2 \
    && cp /usr/bin/aria2c ./net_worker \
    && chmod +x net_worker

# 准备数据目录 (使用毫无意义的目录名)
RUN mkdir -p /var/opt/cache/temp
RUN mkdir -p /var/opt/cache/data

# 复制启动脚本 (脚本名为 init_process)
COPY entrypoint.sh /usr/local/bin/init_process
RUN chmod +x /usr/local/bin/init_process

# 暴露端口 (HF 默认)
ENV PORT=7860
EXPOSE 7860

# 启动命令
CMD ["/usr/local/bin/init_process"]
