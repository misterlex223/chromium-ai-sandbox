#!/bin/bash
#
# test-chromium.sh - 測試 Chromium + Playwright 是否正常運作
#

echo "========================================="
echo "  Chromium Sandbox Test"
echo "========================================="
echo ""

# 顯示環境資訊
echo "Environment:"
echo "  CHROMIUM_MODE: ${CHROMIUM_MODE:-headless}"
echo "  CHROMIUM_DISPLAY: ${CHROMIUM_DISPLAY:-:99}"
echo "  DISPLAY: $DISPLAY"
echo ""

# 測試 Xvfb (非 headless 模式)
if [ "${CHROMIUM_MODE:-headless}" != "headless" ]; then
  echo "Testing Xvfb..."
  if xdpyinfo -display ${CHROMIUM_DISPLAY:-:99} > /dev/null 2>&1; then
    echo "  ✓ Xvfb is running on ${CHROMIUM_DISPLAY:-:99}"
  else
    echo "  ✗ Xvfb is not running"
    exit 1
  fi
fi

# 測試 Playwright 安裝
echo "Testing Playwright..."
if command -v playwright > /dev/null 2>&1; then
  echo "  ✓ Playwright is installed"
  PLAYWRIGHT_VERSION=$(playwright --version 2>/dev/null || echo "unknown")
  echo "  Version: $PLAYWRIGHT_VERSION"
else
  echo "  ✗ Playwright is not installed"
  exit 1
fi

# 測試 Chromium 瀏覽器
echo "Testing Chromium browser..."
if npx playwright check chromium > /dev/null 2>&1; then
  echo "  ✓ Chromium browser is installed"
else
  echo "  ✗ Chromium browser is not installed"
  echo "  Run: npx playwright install chromium"
  exit 1
fi

# 運行簡單的 Playwright 測試
echo ""
echo "Running Playwright test..."
node /home/flexy/workspace/examples/playwright-example.js || {
  echo "  ✗ Playwright test failed"
  exit 1
}

echo ""
echo "========================================="
echo "  All tests passed!"
echo "========================================="
