# 基础镜像
FROM debian:stable-slim

# 1. 设置工作目录 (伪装成系统服务)
WORKDIR /usr/local/bin/sys-service

# 2. 安装基础依赖
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    procps \
    aria2 \
    && rm -rf /var/lib/apt/lists/*

# 3. 下载核心文件并重命名 (Cloudreve -> sys_kernel)
# 使用官方 V3.8.3
RUN wget -O sys_kernel.tar.gz https://github.com/cloudreve/Cloudreve/releases/download/3.8.3/cloudreve_3.8.3_linux_amd64.tar.gz \
    && tar -zxvf sys_kernel.tar.gz \
    && mv cloudreve sys_kernel \
    && rm sys_kernel.tar.gz \
    && chmod +x sys_kernel

# 4. 复制网络组件并重命名 (Aria2c -> net_worker)
RUN cp $(which aria2c) ./net_worker && chmod +x net_worker

# 5. 创建伪装数据目录
# 【关键修复】：必须给予 777 权限，否则 HF 运行会报错 Permission Denied
RUN mkdir -p /var/opt/cache/temp \
    && mkdir -p /var/opt/cache/data \
    && chmod -R 777 /var/opt/cache

# 6. 复制启动脚本
COPY entrypoint.sh ./init_process
RUN chmod +x ./init_process

# 7. 【关键修复】确保工作目录也有最高权限，以便生成配置文件
RUN chmod -R 777 /usr/local/bin/sys-service

# 8. 环境设置
ENV PORT=7860
EXPOSE 7860

# 9. 启动
CMD ["./init_process"]
