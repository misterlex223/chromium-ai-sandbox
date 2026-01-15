#!/bin/bash
#
# init-chromium-sandbox.sh - Chromium Sandbox 初始化腳本
#
# 此腳本是 flexy-sandbox init.sh 的擴展版本
# 它會先執行原本的 flexy-sandbox 初始化，然後啟動 Xvfb/VNC 服務
#

set -e

# 原本的 flexy-sandbox init.sh 路徑
ORIGINAL_INIT="/usr/local/bin/init.sh"

# 檢查原始 init.sh 是否存在
if [ ! -f "$ORIGINAL_INIT" ]; then
  echo "Warning: Original init.sh not found at $ORIGINAL_INIT"
  echo "Running minimal initialization..."
else
  # 執行原始初始化（但在最後不要執行 shell，因為我們要擴展它）
  # 我們需要設定一個標記來告訴原始 init.sh 不要執行最後的 shell
  export CHROMIUM_SANDBOX_INIT=1

  # 執行原始初始化的大部分邏輯
  # 但我們需要在啟動 SSH 之後插入我們的服務

  echo "========================================"
  echo "  Chromium Sandbox Initialization"
  echo "========================================"
  echo "Mode: ${CHROMIUM_MODE:-headless}"
  echo ""
fi

# 執行原始 init.sh 的主要邏輯
# 由於原始腳本最後會 exec shell，我們需要重新實現部分邏輯
# 或者使用不同的方式

# 設定支援中文的 locale
export LANG=zh_TW.UTF-8
export LC_ALL=zh_TW.UTF-8

# 建立常用目錄
mkdir -p /home/flexy/.config

# 初始化 AI 工具
if [ -f /scripts/install-ai-tools.sh ]; then
  echo "========================================"
  echo "  安裝 AI 工具"
  echo "========================================"
  /scripts/install-ai-tools.sh || {
    echo "⚠ AI 工具安裝失敗，但繼續啟動容器"
  }
  echo ""
fi

# 初始化 Qwen 和 Claude 配置
if [ ! -f /home/flexy/.qwen/.__flexy_initialized__ ]; then
  echo "Initializing Qwen config..."
  mkdir -p /home/flexy/.qwen
  touch /home/flexy/.qwen/.__flexy_initialized__
fi

if [ ! -f /home/flexy/.claude/.__flexy_initialized__ ]; then
  echo "Initializing Claude Code configuration..."
  mkdir -p /home/flexy/.claude
  touch /home/flexy/.claude/.__flexy_initialized__
fi

# 初始化 Claude Code 配置（結合預設配置和使用者配置）
echo "Initializing Claude Code configuration..."
mkdir -p /home/flexy/.claude

# 1. 安裝 MCP 配置 → /home/flexy/.claude/.mcp.json
if [ ! -f /home/flexy/.claude/.mcp.json ] && [ -f /tmp/mcp-config.json ]; then
  cp /tmp/mcp-config.json /home/flexy/.claude/.mcp.json
  echo "✓ MCP configuration installed"
  echo "  - Playwright MCP Server enabled"
  echo "  - Tools: launch_browser, navigate, click, fill, screenshot, etc."
elif [ -f /home/flexy/.claude/.mcp.json ]; then
  echo "✓ Using existing MCP configuration"
else
  echo "⚠ No MCP configuration found"
fi

# 2. 安裝 Skill → /home/flexy/.claude/skills/chromium-sandbox/SKILL.md
if [ ! -f /home/flexy/.claude/skills/chromium-sandbox/SKILL.md ] && [ -f /tmp/claude-skill.md ]; then
  mkdir -p /home/flexy/.claude/skills/chromium-sandbox
  cp /tmp/claude-skill.md /home/flexy/.claude/skills/chromium-sandbox/SKILL.md
  echo "✓ Chromium Sandbox skill installed"
  echo "  - Location: /home/flexy/.claude/skills/chromium-sandbox/SKILL.md"
elif [ -f /home/flexy/.claude/skills/chromium-sandbox/SKILL.md ]; then
  echo "✓ Using existing Chromium Sandbox skill"
fi

# 3. 安裝權限配置 → /home/flexy/.claude/settings.local.json
if [ ! -f /home/flexy/.claude/settings.local.json ] && [ -f /tmp/settings.local.json ]; then
  cp /tmp/settings.local.json /home/flexy/.claude/settings.local.json
  echo "✓ Claude Code permissions installed"
elif [ -f /home/flexy/.claude/settings.local.json ]; then
  echo "✓ Using existing permissions configuration"
fi

# 4. 安裝 Frontend Tester Plugin → /home/flexy/.claude/plugins/frontend-tester
if [ ! -d /home/flexy/.claude/plugins/frontend-tester ] && [ -d /tmp/frontend-tester-plugin ]; then
  mkdir -p /home/flexy/.claude/plugins
  cp -r /tmp/frontend-tester-plugin /home/flexy/.claude/plugins/frontend-tester
  echo "✓ Frontend Tester plugin installed"
  echo "  - /test-spec: 執行前端測試"
  echo "  - /test-spec-template: 產生規格範本"
  echo "  - Agent: frontend-test-engineer"
elif [ -d /home/flexy/.claude/plugins/frontend-tester ]; then
  echo "✓ Using existing Frontend Tester plugin"
fi

# 設定 Git 初始配置
if [ ! -f /home/flexy/.gitconfig ]; then
  GIT_USERNAME=${GIT_USERNAME:-"Flexy"}
  GIT_EMAIL=${GIT_EMAIL:-"flexy@example.com"}
  git config --global user.email "$GIT_EMAIL"
  git config --global user.name "$GIT_USERNAME"
fi

WORKING_DIRECTORY=${WORKING_DIRECTORY:-/home/flexy/workspace}

# 啟動 SSH 服務
echo "========================================"
echo "  啟動 SSH 服務"
echo "========================================"
sudo /usr/sbin/sshd
echo "SSH 服務已啟動"
echo ""

# ============================================================================
# Chromium Sandbox: 啟動 Xvfb/VNC 服務
# ============================================================================
if [ "$CHROMIUM_MODE" != "headless" ]; then
  echo "========================================"
  echo "  Chromium Sandbox - Display Services"
  echo "========================================"
  /scripts/start-xvfb.sh || {
    echo "⚠ Xvfb/VNC 啟動失敗，但繼續啟動容器"
  }
  echo ""
fi

# 啟動 CoSpec AI Markdown Editor
if [ "${DISABLE_COSPEC_AI:-false}" != "true" ]; then
  echo "========================================"
  echo "  啟動 CoSpec AI Markdown Editor"
  echo "========================================"
  echo "Markdown Editor 將在以下位置啟動："
  echo "- 服務: http://localhost:${COSPEC_PORT:-9280}"
  echo ""

  mkdir -p ${MARKDOWN_DIR:-$WORKING_DIRECTORY}
  npx cospec-ai --port ${COSPEC_PORT:-9280} --markdown-dir ${MARKDOWN_DIR:-$WORKING_DIRECTORY} > /home/flexy/cospec.log 2>&1 &
  COSPEC_PID=$!
  echo "CoSpec AI 已啟動 (PID: $COSPEC_PID)"
  echo ""
fi

# 顯示環境資訊
echo "========================================"
echo "  Chromium Sandbox Ready"
echo "========================================"
echo "Node.js version: $(node --version)"
echo "Chromium Mode: ${CHROMIUM_MODE:-headless}"
if [ "${CHROMIUM_MODE:-headless}" = "vnc" ]; then
  echo "noVNC URL: http://localhost:${NOVNC_PORT:-6900}"
fi
echo "========================================"
echo ""

# 檢查是否啟用 WebTTY 模式
if [ "$ENABLE_WEBTTY" = "true" ]; then
  echo "========================================"
  echo "  啟動 WebTTY 模式"
  echo "========================================"
  echo "WebTTY 將在 http://localhost:9681 啟動"
  echo "工作目錄: $WORKING_DIRECTORY"

  cd "$WORKING_DIRECTORY" || {
    echo "警告: 無法切換到工作目錄 $WORKING_DIRECTORY"
    cd /home/flexy/workspace
  }

  # 啟動 AI 會話監控器
  if [ -f /usr/local/bin/ai-session-monitor.js ]; then
    echo "啟動 AI 會話監控器..."
    node /usr/local/bin/ai-session-monitor.js > /home/flexy/ai-monitor.log 2>&1 &
    AI_MONITOR_PID=$!
    echo "AI 會話監控器已啟動 (PID: $AI_MONITOR_PID)"
  fi

  # 處理停止信號
  trap "kill $COSPEC_PID $AI_MONITOR_PID 2>/dev/null; exit" SIGINT SIGTERM

  sleep 2
  LANG=zh_TW.UTF-8 LC_ALL=zh_TW.UTF-8 ttyd -p 9681 -W tmux new -A -s shared_session
else
  # 預設模式：切換到工作目錄並啟動 bash shell
  cd "$WORKING_DIRECTORY" || {
    echo "警告: 無法切換到工作目錄 $WORKING_DIRECTORY"
    cd /home/flexy/workspace
  }

  if [ "${DISABLE_COSPEC_AI:-false}" != "true" ]; then
    trap "kill $COSPEC_PID; exit" SIGINT SIGTERM
  else
    trap "exit" SIGINT SIGTERM
  fi

  exec "$@"
fi
