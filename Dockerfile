FROM debian:stable-slim

# 1. 设置工作目录
WORKDIR /usr/local/bin/sys-service

# 2. 安装基础依赖
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    procps \
    aria2 \
    && rm -rf /var/lib/apt/lists/*

# 3. 下载 Cloudreve 并重命名 (Cloudreve -> sys_kernel)
RUN wget -O sys_kernel.tar.gz https://github.com/cloudreve/Cloudreve/releases/download/3.8.3/cloudreve_3.8.3_linux_amd64.tar.gz \
    && tar -zxvf sys_kernel.tar.gz \
    && mv cloudreve sys_kernel \
    && rm sys_kernel.tar.gz \
    && chmod +x sys_kernel

# 4. 复制并重命名 Aria2 (Aria2c -> net_worker)
RUN cp /usr/bin/aria2c ./net_worker \
    && chmod +x net_worker

# 5. 创建伪装数据目录并给满权限
RUN mkdir -p /var/opt/cache/temp \
    && mkdir -p /var/opt/cache/data \
    && mkdir -p /var/opt/cache/conf \
    && chmod -R 777 /var/opt/cache

# 6. 复制启动脚本
COPY entrypoint.sh ./init_process
RUN chmod +x ./init_process

# 7. 赋予工作目录权限
RUN chmod -R 777 /usr/local/bin/sys-service

ENV PORT=7860
EXPOSE 7860

CMD ["./init_process"]
