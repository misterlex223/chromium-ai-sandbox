# Chromium-Sandbox 實作計劃

## 專案概述

將 flexy-sandbox 擴展為 chromium-sandbox，加入 Xvfb + Chromium + Playwright + VNC 功能，讓 AI 模型能在沙盒環境中進行前端 App 測試任務。

## 技術架構

```
┌─────────────────────────────────────────────────────────────┐
│                    chromium-sandbox                         │
├─────────────────────────────────────────────────────────────┤
│  AI Tools (Claude/Qwen/Gemini)                              │
│       ↓                                                     │
│  Playwright (Node.js)                                       │
│       ↓                                                     │
│  Chromium Browser                                           │
│       ↓                                                     │
│  Xvfb (Virtual Display) ──→ x11vnc (VNC Server)            │
│                              ↓                              │
│                         noVNC (Web VNC Client)              │
└─────────────────────────────────────────────────────────────┘
```

## 核心組件

| 組件 | 用途 | 版本 |
|------|------|------|
| Xvfb | 虛擬顯示伺服器 | 1.20+ |
| x11vnc | VNC 伺服器 | 0.9+ |
| noVNC | HTML5 VNC 客戶端 | latest |
| Chromium | 瀏覽器 | latest |
| Playwright | 瀏覽器自動化框架 | latest |

## 環境變數設計

```bash
# Chrome/Playwright 模式
CHROMIUM_MODE=headless     # headless | xvfb | vnc
CHROMIUM_RESOLUTION=1920x1080x24
CHROMIUM_DISPLAY=:99

# VNC 配置
VNC_PORT=5900
NOVNC_PORT=6900
VNC_PASSWORD=dockerSandbox
```

## 實作階段

### Phase 1: Dockerfile 修改

**檔案**: `Dockerfile`

**新增安裝項目**:
```dockerfile
# Xvfb 及相關套件
xvfb \
x11vnc \
xvfb \
fluxbox \          # 輕量級視窗管理器
fonts-liberation \ # 字型
fonts-noto-color-emoji \
fonts-wqy-zenhei

# noVNC (從 GitHub 安裝)
# Firefox/Chromium 依賴
libatk-bridge2.0-0 \
libdrm2 \
libxkbcommon0 \
libgbm1
```

**新增環境變數**:
```dockerfile
ENV CHROMIUM_MODE=headless
ENV CHROMIUM_RESOLUTION=1920x1080x24
ENV CHROMIUM_DISPLAY=:99
ENV VNC_PORT=5900
ENV NOVNC_PORT=6900
ENV VNC_PASSWORD=dockerSandbox
```

**新增 Expose ports**:
```dockerfile
EXPOSE 5900 6900
```

**安裝 Playwright**:
```dockerfile
# 安裝 Playwright 和瀏覽器
RUN npm install -g playwright@latest && \
    npx playwright install --with-deps chromium
```

---

### Phase 2: Xvfb/VNC 啟動腳本

**新檔案**: `scripts/start-xvfb.sh`

```bash
#!/bin/bash
# 根據 CHROMIUM_MODE 啟動對應的顯示服務
# - headless: 不啟動 Xvfb (Playwright 內建支援)
# - xvfb: 啟動 Xvfb 無顯示
# - vnc: 啟動 Xvfb + x11vnc + noVNC
```

**新檔案**: `scripts/start-vnc.sh`

```bash
#!/bin/bash
# 啟動 x11vnc 和 noVNC
```

---

### Phase 3: 修改 init.sh

**檔案**: `init.sh`

在啟動 SSH 服務後，加入：

```bash
# 啟動 Xvfb/VNC 服務（根據 CHROMIUM_MODE）
if [ "$CHROMIUM_MODE" != "headless" ]; then
  /scripts/start-xvfb.sh
fi
```

---

### Phase 4: Playwright 測試範例

**新檔案**: `examples/playwright-example.js`

```javascript
// 基礎 Playwright 測試範例
// 展示如何在沙盒中進行瀏覽器測試
```

**新檔案**: `examples/ai-playwright-helper.js`

```javascript
// AI 友好的 Playwright 包裝層
// 提供簡化的 API 讓 AI 模型容易呼叫
```

---

### Phase 5: README 更新

**檔案**: `README.md`

新增章節：
- 功能說明 (Chromium + Playwright + VNC)
- 環境變數配置
- 使用範例
- VNC 連線方式
- Playwright 測試範例

---

### Phase 6: 測試腳本

**新檔案**: `scripts/test-chromium.sh`

```bash
#!/bin/bash
# 測試 Chromium + Playwright 是否正常運作
```

---

## 檔案變更摘要

| 檔案 | 動作 | 說明 |
|------|------|------|
| `Dockerfile` | 修改 | 加入 Xvfb/VNC/Chromium/Playwright |
| `init.sh` | 修改 | 啟動 Xvfb/VNC 服務 |
| `scripts/start-xvfb.sh` | 新增 | Xvfb 啟動腳本 |
| `scripts/start-vnc.sh` | 新增 | VNC 啟動腳本 |
| `scripts/test-chromium.sh` | 新增 | 測試腳本 |
| `examples/playwright-example.js` | 新增 | Playwright 範例 |
| `examples/ai-playwright-helper.js` | 新增 | AI 友好 API |
| `README.md` | 修改 | 更新文件 |
| `docs/CHROMIUM-GUIDE.md` | 新增 | 詳細使用指南 |

---

## 使用範例

### 1. 無頭模式 (預設)
```bash
docker run -it --rm \
  -v $(pwd):/home/flexy/workspace \
  chromium-sandbox
```

### 2. VNC 模式 (可視化調試)
```bash
docker run -it --rm \
  -e CHROMIUM_MODE=vnc \
  -p 6900:6900 \
  -v $(pwd):/home/flexy/workspace \
  chromium-sandbox

# 瀏覽器開啟: http://localhost:6900
```

### 3. Playwright 測試
```javascript
const { chromium } = require('playwright');

const browser = await chromium.launch({
  headless: process.env.CHROMIUM_MODE === 'headless'
});

const page = await browser.newPage();
await page.goto('https://example.com');
// ... 測試邏輯
```

---

## 注意事項

1. **安全性**: VNC 密碼預設為 dockerSandbox，生產環境應修改
2. **資源**: Chromium 記憶體消耗較大，建議 Docker 容器至少 2GB RAM
3. **字型**: 已包含中日韓字型支援
4. **網路**: 沙盒內網路與主機隔離，需注意連線問題

---

## 預期成果

完成後，chromium-sandbox 將支援：

- [x] AI 模型透過 Playwright 控制 Chromium
- [x] 無頭模式（快速、自動化）
- [x] VNC 模式（可視化調試）
- [x] 完整的前端測試環境
- [x] 與現有 flexy-sandbox AI 工具無縫整合
