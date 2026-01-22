#!/bin/bash
#
# playwright-mcp-wrapper.sh - Playwright MCP Server Wrapper
#
# 此 wrapper 確保 Playwright MCP server 在正確的環境變數下啟動
# 根據 CHROMIUM_MODE 自動切換 headless/headed 模式
#

# 設定 chromium-sandbox 相關環境變數
export CHROMIUM_MODE=${CHROMIUM_MODE:-headless}
export CHROMIUM_DISPLAY=${CHROMIUM_DISPLAY:-:99}
export CHROMIUM_RESOLUTION=${CHROMIUM_RESOLUTION:-1920x1080x24}

# 設定 DISPLAY（Playwright 需要此環境變數來啟動非 headless 瀏覽器）
export DISPLAY=$CHROMIUM_DISPLAY

# 設定 Playwright 瀏覽器路徑（讓 Playwright MCP 找到 Chromium）
export PLAYWRIGHT_BROWSERS_PATH=${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}

# 配置檔案路徑
CONFIG_FILE="/home/flexy/.claude/playwright-mcp.config.json"

# 根據 CHROMIUM_MODE 生成配置
/usr/local/bin/generate-playwright-config.sh "$CONFIG_FILE"

# 檢查是否已指定 --browser 參數，如果沒有則使用 chromium
if [[ ! " $* " =~ " --browser " ]]; then
  set -- "$@" --browser chromium
fi

# 執行 Playwright MCP server
exec npx @playwright/mcp "$@"
