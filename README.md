# Chromium AI Sandbox

> 瀏覽器自動化沙盒環境，讓 AI 模型能在 Docker 容器中進行前端 App 測試任務

Chromium AI Sandbox 是基於 [flexy-sandbox](https://github.com/misterlex223/flexy-sandbox) 擴展的 Docker 映像，整合了 **Xvfb + Chromium + Playwright + VNC + MCP**，提供完整的瀏覽器自動化測試環境。

## 特性

- 🤖 **AI 友好設計** - 內建 Microsoft Playwright MCP Server
- 🌐 **Chromium 瀏覽器** - 最新版本的 Chromium 瀏覽器
- 🎭 **Playwright 框架** - 現代化的瀏覽器自動化框架
- 🖥️ **Xvfb 虛擬顯示** - 無需實體顯示器即可運行 GUI 應用
- 🔍 **VNC 遠端觀看** - 透過 noVNC 在瀏覽器中查看測試過程
- 🔌 **MCP 支援** - Claude Code 原生支援，無需編寫程式碼

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

## Claude Code + MCP

chromium-ai-sandbox 內建 **Microsoft Playwright MCP Server**，透過 `frontend-tester` plugin 提供。啟動容器後，Claude Code 可以直接使用瀏覽器自動化工具。

> **Plugin 安裝**: `frontend-tester` plugin 會在容器首次啟動時，自動從 `aintandem-agent-team` marketplace 安裝。

### MCP 提供的工具

| 工具 | 說明 |
|------|------|
| `launch_browser` | 啟動瀏覽器 |
| `close_browser` | 關閉瀏覽器 |
| `navigate_to` | 導航到指定 URL |
| `screenshot` | 截取頁面截圖 |
| `click` | 點擊頁面元素 |
| `fill` | 填寫表單輸入框 |
| `select` | 選擇下拉選項 |
| `hover` | 滑鼠懸停 |
| `get_text` | 獲取元素文字 |
| `get_url` | 獲取當前 URL |
| `go_back` | 返回上一頁 |
| `go_forward` | 前往下一頁 |
| `evaluate` | 執行 JavaScript |

### 使用範例

在 Claude Code 中：

```bash
# 啟動瀏覽器並訪問網站
User: "幫我開啟瀏覽器，訪問 https://example.com，然後截圖"
Claude: 會自動呼叫 MCP 工具完成任務

# 測試登入功能
User: "測試我的登入頁面，帳號是 test@example.com，密碼是 password123"
Claude: 會自動導航、填寫表單、點擊登入、驗證結果

# 網頁爬蟲
User: "幫我抓取這個頁面的所有文章標題"
Claude: 會自動導航、提取資料、回傳結果
```

### MCP 配置

容器啟動後，`frontend-tester` plugin 會自動安裝，並提供 Playwright MCP Server。

Plugin 會透過 wrapper script (`/usr/local/bin/playwright-mcp-wrapper.sh`) 啟動 MCP server，確保環境變數（如 `DISPLAY`）正確設定。

**手動安裝 Plugin**（如需重新安裝）：
```bash
claude plugin marketplace add https://github.com/misterlex223/aintandem-agent-team
claude plugin install frontend-tester@aintandem-agent-team
```

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

## 進階使用

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

### AI Helper

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
├── config/
│   ├── skill.md                        # Claude Code Skill 說明
│   └── settings.local.json             # Claude Code 權限配置
├── docs/
│   └── CHROMIUM-GUIDE.md               # 詳細使用指南
├── examples/
│   ├── playwright-example.js           # Playwright 基礎範例
│   ├── ai-playwright-helper.js         # AI 友好的 API 包裝層
│   └── keep-open.js                    # 保持瀏覽器開啟範例
└── scripts/
    ├── init-chromium-sandbox.sh        # 容器初始化腳本
    ├── playwright-mcp-wrapper.sh       # Playwright MCP wrapper script
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

# 測試 MCP 工具
docker exec -it chromium-test npx @playwright/mcp
```

## 文件

- [Chromium 使用指南](docs/CHROMIUM-GUIDE.md) - 詳細的使用說明和故障排除

## 授權

MIT License

## 相關專案

- [flexy-sandbox](https://github.com/misterlex223/flexy-sandbox) - 基礎開發環境
- [Microsoft Playwright MCP](https://github.com/microsoft/playwright-mcp) - MCP Server 實作
- [Playwright](https://playwright.dev/) - 瀏覽器自動化框架
- [noVNC](https://github.com/novnc/noVNC) - HTML5 VNC 客戶端
