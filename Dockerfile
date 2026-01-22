# Chromium-Sandbox Dockerfile
# Extends the base Flexy Dev Sandbox image with Chromium automation capabilities
FROM ghcr.io/misterlex223/flexy-sandbox:latest

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone to avoid interactive tzdata prompt
ARG TZ=Etc/UTC
ENV TZ=${TZ}
RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ | sudo tee /etc/timezone

# ============================================================================
# Chromium Sandbox: 安裝 Xvfb、VNC、noVNC、Chromium 相關套件
# ============================================================================
# Xvfb: X Virtual Frame Buffer - 提供虛擬顯示環境
# x11vnc: VNC 伺服器 - 允許遠端查看 Xvfb 顯示
# fluxbox: 輕量級視窗管理器
# fonts-*: 字型支援 (包含中日韓字型)
# lib*: Chromium 瀏覽器依賴套件
RUN sudo apt-get update && sudo apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libgbm1 \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 \
    libxrandr2 \
    libpango-1.0-0 \
    libcairo2 \
    libxdamage1 \
    libxcomposite1 \
    && sudo rm -rf /var/lib/apt/lists/*

# 安裝 noVNC (HTML5 VNC Client)
RUN cd /tmp && \
    git clone --depth 1 https://github.com/novnc/noVNC.git && \
    sudo mv noVNC /opt/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify && \
    sudo rm -rf /tmp/noVNC

# 安裝 Playwright 和 Chromium 瀏覽器
RUN npm install -g playwright && \
    npx playwright install --with-deps chromium && \
    npx playwright install-deps chromium

# 安裝 Playwright MCP Server
# 讓 Claude Code 和其他 MCP 客戶端能夠控制瀏覽器
RUN npm install -g @playwright/mcp

# 複製 chromium-sandbox 特定的腳本
COPY scripts/start-xvfb.sh /scripts/start-xvfb.sh
COPY scripts/test-chromium.sh /scripts/test-chromium.sh
RUN sudo chmod +x /scripts/start-xvfb.sh /scripts/test-chromium.sh

# 複製範例程式
COPY examples/ /home/flexy/examples/
RUN sudo chown -R flexy:flexy /home/flexy/examples

# 複製 Claude Code 配置檔 (由 init-chromium-sandbox.sh 安裝到容器內)
# MCP 配置 → /home/flexy/.claude/.mcp.json
COPY config/.mcp.json /tmp/mcp-config.json
# Skill 說明 → /home/flexy/.claude/skills/chromium-sandbox/SKILL.md
COPY config/skill.md /tmp/claude-skill.md
# 權限配置 → /home/flexy/.claude/settings.local.json
COPY config/settings.local.json /tmp/settings.local.json

# 注意: Frontend Tester Plugin 已移至 aintandem-agent-team marketplace
# 請使用 Claude Code 的 marketplace 功能安裝:
# https://github.com/misterlex223/aintandem-agent-team

# 複製文檔
COPY docs/CHROMIUM-GUIDE.md /home/flexy/docs/

# 覆蓋 entrypoint 使用 chromium-sandbox 的 init 腳本
COPY scripts/init-chromium-sandbox.sh /usr/local/bin/init-chromium-sandbox.sh
RUN sudo chmod +x /usr/local/bin/init-chromium-sandbox.sh

# ============================================================================
# Chromium Sandbox 環境變數
# ============================================================================
# CHROMIUM_MODE: headless (無頭) | xvfb (虛擬顯示) | vnc (VNC + noVNC)
ENV CHROMIUM_MODE=headless
# CHROMIUM_RESOLUTION: 虛擬顯示解析度 (寬x高x色深)
ENV CHROMIUM_RESOLUTION=1920x1080x24
# CHROMIUM_DISPLAY: X11 顯示編號
ENV CHROMIUM_DISPLAY=:99
# VNC_PORT: VNC 伺服器端口
ENV VNC_PORT=5900
# NOVNC_PORT: noVNC Web 客戶端端口
ENV NOVNC_PORT=6900
# VNC_PASSWORD: VNC 連線密碼
ENV VNC_PASSWORD=dockerSandbox

# Set working directory
WORKDIR /home/flexy/workspace

# Expose ports (base image already has 9681, 9280, 22)
# VNC server
EXPOSE 5900
# noVNC Web client
EXPOSE 6900

# Override the base image's entrypoint to use chromium-sandbox extension script
ENTRYPOINT ["/usr/local/bin/init-chromium-sandbox.sh"]
CMD ["/bin/bash"]
