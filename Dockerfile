# 第一阶段：构建依赖
FROM python:3.9.5-slim-buster AS builder

# 安装编译所需的工具
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    libffi-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 升级 pip，避免 PEP 517 相关错误
RUN pip install --upgrade pip

# 设置工作目录
WORKDIR /app

# 复制代码和依赖文件
COPY requirements.txt /app/

# 预编译依赖
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# 第二阶段：精简运行环境
FROM python:3.9.5-slim-buster

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone

# 复制编译好的 Python 依赖
COPY --from=builder /install /usr/local

# 复制应用代码
COPY . /app

# 设置工作目录
WORKDIR /app

# 删除不必要的目录
RUN rm -rf docs fcb-fronted

# 暴露端口
EXPOSE 12345

# 启动应用
CMD ["python", "main.py"]
