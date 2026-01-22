#!/bin/bash
#
# generate-playwright-config.sh - 根據 CHROMIUM_MODE 生成 Playwright MCP 配置
#
# 根據環境變數自動切換 headless/headed 模式
#

# 設定默認值
CHROMIUM_MODE=${CHROMIUM_MODE:-headless}
CHROMIUM_DISPLAY=${CHROMIUM_DISPLAY:-:99}

# Chromium 可執行檔案路徑（自動偵測最新版本）
CHROMIUM_BASE="/home/flexy/.cache/ms-playwright"
if [ -d "$CHROMIUM_BASE/chromium-1207" ]; then
  CHROMIUM_PATH="$CHROMIUM_BASE/chromium-1207/chrome-linux64/chrome"
elif [ -d "$CHROMIUM_BASE/chromium-1200" ]; then
  CHROMIUM_PATH="$CHROMIUM_BASE/chromium-1200/chrome-linux64/chrome"
else
  # 嘗試自動找到 chromium 目錄
  CHROMIUM_DIR=$(find "$CHROMIUM_BASE" -maxdepth 1 -type d -name "chromium-*" | sort -V | tail -1)
  if [ -n "$CHROMIUM_DIR" ]; then
    CHROMIUM_PATH="$CHROMIUM_DIR/chrome-linux64/chrome"
  else
    CHROMIUM_PATH="$CHROMIUM_BASE/chromium-1207/chrome-linux64/chrome"
  fi
fi

# 輸出配置檔案路徑
CONFIG_OUTPUT="${1:-/home/flexy/.claude/playwright-mcp.config.json}"

# 判斷是否使用 headed 模式
# headless = 無頭模式
# xvfb | vnc = 有頭模式（需要 DISPLAY）
if [[ "$CHROMIUM_MODE" == "headless" ]]; then
  HEADLESS=true
else
  HEADLESS=false
fi

# 生成 JSON 配置
cat > "$CONFIG_OUTPUT" << EOF
{
  "browser": {
    "launchOptions": {
      "executablePath": "$CHROMIUM_PATH",
      "args": [
        "--no-sandbox",
        "--disable-dev-shm-usage"
      ],
      "headless": $HEADLESS
    }
  }
}
EOF

# 輸出診斷信息（可選）
if [[ "${VERBOSE:-false}" == "true" ]]; then
  echo "[generate-playwright-config]" >&2
  echo "  CHROMIUM_MODE: $CHROMIUM_MODE" >&2
  echo "  CHROMIUM_DISPLAY: $CHROMIUM_DISPLAY" >&2
  echo "  HEADLESS: $HEADLESS" >&2
  echo "  CHROMIUM_PATH: $CHROMIUM_PATH" >&2
  echo "  CONFIG: $CONFIG_OUTPUT" >&2
fi
