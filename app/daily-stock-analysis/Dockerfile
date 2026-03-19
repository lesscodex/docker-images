# ===================================
# A股自选股智能分析系统 - Docker 镜像
# ===================================
# 多阶段构建：源码获取 + 前端打包 + 后端运行

FROM alpine/git AS source

ARG REPO_URL=https://github.com/ZhuLinsen/daily_stock_analysis.git
ARG REPO_REF=main

WORKDIR /src
RUN git clone "$REPO_URL" repo \
    && cd repo \
    && git checkout "$REPO_REF"

FROM node:20-slim AS web-builder

WORKDIR /app/apps/dsa-web

COPY --from=source /src/repo/apps/dsa-web/package.json /src/repo/apps/dsa-web/package-lock.json ./
RUN npm ci

COPY --from=source /src/repo/apps/dsa-web/ ./
RUN npm run build

# Pin to bookworm: wkhtmltopdf was removed from Debian testing (2025)
FROM python:3.11-slim-bookworm

# 设置工作目录
WORKDIR /app

# 设置时区为上海
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装系统依赖（wkhtmltopdf 含 wkhtmltoimage，用于 Markdown 转图片 Issue #289）
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
    wkhtmltopdf \
    fontconfig \
    libjpeg62-turbo \
    libxrender1 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY --from=source /src/repo/requirements.txt ./

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY --from=source /src/repo/*.py ./
COPY --from=source /src/repo/api/ ./api/
COPY --from=source /src/repo/data_provider/ ./data_provider/
COPY --from=source /src/repo/bot/ ./bot/
COPY --from=source /src/repo/patch/ ./patch/
COPY --from=source /src/repo/src/ ./src/
COPY --from=source /src/repo/strategies/ ./strategies/
COPY --from=web-builder /app/static ./static/

# 创建数据目录
RUN mkdir -p /app/data /app/logs /app/reports

# 设置环境变量默认值
ENV PYTHONUNBUFFERED=1
ENV LOG_DIR=/app/logs
ENV DATABASE_PATH=/app/data/stock_analysis.db
# Web/API service
ENV WEBUI_HOST=0.0.0.0
ENV API_PORT=8000

# 暴露 API 端口
EXPOSE 8000

# 数据卷（持久化数据）
VOLUME ["/app/data", "/app/logs", "/app/reports"]

# 健康检查（FastAPI 模式）
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/api/health || curl -f http://localhost:8000/health \
    || python -c "import sys; sys.exit(0)"

# 默认命令（可被覆盖）
CMD ["python", "main.py", "--schedule"]
