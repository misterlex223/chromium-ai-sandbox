#!/bin/bash
#
# start-xvfb.sh - 啟動 Xvfb 虛擬顯示伺服器
#
# 根據 CHROMIUM_MODE 環境變數啟動對應的顯示服務:
# - headless: 不啟動 Xvfb (Playwright 內建支援)
# - xvfb: 啟動 Xvfb 無顯示
# - vnc: 啟動 Xvfb + x11vnc + noVNC
#

set -e

# 環境變數
CHROMIUM_MODE=${CHROMIUM_MODE:-headless}
CHROMIUM_DISPLAY=${CHROMIUM_DISPLAY:-:99}
CHROMIUM_RESOLUTION=${CHROMIUM_RESOLUTION:-1920x1080x24}
VNC_PORT=${VNC_PORT:-5900}
NOVNC_PORT=${NOVNC_PORT:-6900}
VNC_PASSWORD=${VNC_PASSWORD:-dockerSandbox}

# 顯示編號 (去掉 :)
DISPLAY_NUM=${CHROMIUM_DISPLAY#:}

echo "========================================="
echo "  Chromium Sandbox - Display Setup"
echo "========================================="
echo "Mode: $CHROMIUM_MODE"
echo "Display: $CHROMIUM_DISPLAY"
echo "Resolution: $CHROMIUM_RESOLUTION"
echo "========================================="

# Headless 模式 - 不啟動 Xvfb
if [ "$CHROMIUM_MODE" = "headless" ]; then
  echo "Headless mode: Xvfb not started"
  echo "Playwright will use built-in headless mode"
  export DISPLAY=$CHROMIUM_DISPLAY
  exit 0
fi

# 建立 Xvfb lock 目錄
sudo mkdir -p /tmp/.X11-unix
sudo chown -R flexy:flexy /tmp/.X11-unix

# 啟動 Xvfb
echo "Starting Xvfb on $CHROMIUM_DISPLAY..."
Xvfb $CHROMIUM_DISPLAY -screen 0 $CHROMIUM_RESOLUTION -ac +extension GLX +render -noreset &
XVFB_PID=$!

# 等待 Xvfb 啟動
sleep 2

# 設定 DISPLAY 環境變數
export DISPLAY=$CHROMIUM_DISPLAY

# 檢查 Xvfb 是否啟動成功
if ! xdpyinfo -display $CHROMIUM_DISPLAY > /dev/null 2>&1; then
  echo "ERROR: Xvfb failed to start on $CHROMIUM_DISPLAY"
  exit 1
fi

echo "Xvfb started successfully (PID: $XVFB_PID)"

# 啟動視窗管理器 (fluxbox) - 讓視窗有正常邊框和標題
echo "Starting fluxbox window manager..."
fluxbox > /dev/null 2>&1 &
FLUXBOX_PID=$!
echo "Fluxbox started (PID: $FLUXBOX_PID)"

# VNC 模式 - 啟動 x11vnc 和 noVNC
if [ "$CHROMIUM_MODE" = "vnc" ]; then
  echo "========================================="
  echo "  Starting VNC Services"
  echo "========================================="
  echo "VNC Port: $VNC_PORT"
  echo "noVNC Port: $NOVNC_PORT"
  echo "Note: Running in no-password mode (development)"
  echo "========================================="

  # 啟動 x11vnc (使用 -nopw 無密碼模式，適合開發環境)
  echo "Starting x11vnc..."
  x11vnc -display $CHROMIUM_DISPLAY \
    -rfbport $VNC_PORT \
    -forever \
    -shared \
    -nopw \
    -xkb \
    > /home/flexy/x11vnc.log 2>&1 &
  X11VNC_PID=$!
  echo "x11vnc started (PID: $X11VNC_PID)"

  # 啟動 noVNC
  echo "Starting noVNC..."
  /opt/noVNC/utils/novnc_proxy --vnc localhost:$VNC_PORT --port $NOVNC_PORT > /home/flexy/novnc.log 2>&1 &
  NOVNC_PID=$!
  echo "noVNC started (PID: $NOVNC_PID)"
  echo ""
  echo "========================================="
  echo "  VNC Access Information"
  echo "========================================="
  echo "noVNC URL: http://localhost:$NOVNC_PORT"
  echo "Note: No password required (development mode)"
  echo "========================================="
fi

# 保存 PID 到檔案，方便後續清理
echo $XVFB_PID > /tmp/xvfb.pid
echo $FLUXBOX_PID > /tmp/fluxbox.pid

if [ "$CHROMIUM_MODE" = "vnc" ]; then
  echo $X11VNC_PID > /tmp/x11vnc.pid
  echo $NOVNC_PID > /tmp/novnc.pid
fi

echo ""
echo "Display services ready!"
echo "DISPLAY=$DISPLAY"
