# Chromium AI Sandbox

> 瀏覽器自動化沙盒環境，讓 AI 模型能在 Docker 容器中進行前端 App 測試任務

Chromium AI Sandbox 是基於 [flexy-sandbox](https://github.com/misterlex223/flexy-sandbox) 擴展的 Docker 映像，整合了 **Xvfb + Chromium + Playwright + VNC**，提供完整的瀏覽器自動化測試環境。

## 特性

- 🤖 **AI 友好設計** - 簡化的 API，讓 AI 模型容易操作瀏覽器
- 🌐 **Chromium 瀏覽器** - 最新版本的 Chromium 瀏覽器
- 🎭 **Playwright 框架** - 現代化的瀏覽器自動化框架
- 🖥️ **Xvfb 虛擬顯示** - 無需實體顯示器即可運行 GUI 應用
- 🔍 **VNC 遠端觀看** - 透過 noVNC 在瀏覽器中查看測試過程
- 📦 **All-in-One** - 單一 Docker 映像包含所有必要組件

## 快速開始

### 建置映像

```bash
git clone https://github.com/misterlex223/chromium-ai-sandbox.git
cd chromium-ai-sandbox
docker build -t chromium-ai-sandbox .
```

### 運行容器

#### 無頭模式（預設）

```bash
docker run -it --rm \
  -v $(pwd):/home/flexy/workspace \
  chromium-ai-sandbox
```

#### VNC 模式（可視化調試）

```bash
docker run -it --rm \
  -e CHROMIUM_MODE=vnc \
  -p 6900:6900 \
  -v $(pwd):/home/flexy/workspace \
  chromium-ai-sandbox
```

然後在瀏覽器開啟：**http://localhost:6900**

## 運行模式

| 模式 | 說明 | VNC | 用途 |
|------|------|-----|------|
| `headless` | 純無頭模式 | ❌ | 自動化測試、CI/CD |
| `xvfb` | 虛擬顯示，無遠端 | ❌ | 需要顯示環境的測試 |
| `vnc` | 完整 VNC + noVNC | ✅ | 可視化調試、開發 |

## 環境變數

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `CHROMIUM_MODE` | `headless` | 運行模式 |
| `CHROMIUM_DISPLAY` | `:99` | X11 顯示編號 |
| `CHROMIUM_RESOLUTION` | `1920x1080x24` | 虛擬顯示解析度 |
| `NOVNC_PORT` | `6900` | noVNC Web 端口 |

## 使用範例

### 基礎 Playwright

```javascript
const { chromium } = require('playwright');

const browser = await chromium.launch({
  headless: process.env.CHROMIUM_MODE === 'headless'
});

const page = await browser.newPage();
await page.goto('https://example.com');
await page.screenshot({ path: '/tmp/screenshot.png' });
await browser.close();
```

### AI Helper（推薦）

```javascript
const { createHelper } = require('/home/flexy/examples/ai-playwright-helper.js');

const browser = createHelper();

await browser.launch();
await browser.goto('https://example.com');
await browser.title();
await browser.screenshot('homepage');
await browser.close();
```

## 專案結構

```
chromium-ai-sandbox/
├── Dockerfile                          # Docker 映像定義
├── README.md                           # 本文件
├── docs/
│   └── CHROMIUM-GUIDE.md               # 詳細使用指南
├── examples/
│   ├── playwright-example.js           # Playwright 基礎範例
│   └── ai-playwright-helper.js         # AI 友好的 API 包裝層
└── scripts/
    ├── init-chromium-sandbox.sh        # 容器初始化腳本
    ├── start-xvfb.sh                   # Xvfb/VNC 啟動腳本
    └── test-chromium.sh                # 測試腳本
```

## 基礎映像

本專案基於 [ghcr.io/misterlex223/flexy-sandbox:latest](https://github.com/misterlex223/flexy-sandbox) 建構，繼承了以下功能：

- Node.js (最新 LTS)
- Python 3
- Git 和 GitHub CLI
- WebTTY (ttyd + tmux)
- CoSpec AI Markdown Editor

## 測試

```bash
# 在容器內執行測試
./scripts/test-chromium.sh
```

## 文件

- [Chromium 使用指南](docs/CHROMIUM-GUIDE.md) - 詳細的使用說明和故障排除

## 授權

MIT License

## 相關專案

- [flexy-sandbox](https://github.com/misterlex223/flexy-sandbox) - 基礎開發環境
- [Playwright](https://playwright.dev/) - 瀏覽器自動化框架
- [noVNC](https://github.com/novnc/noVNC) - HTML5 VNC 客戶端
