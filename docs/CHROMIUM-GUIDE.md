# Chromium Sandbox 使用指南

## 概述

chromium-sandbox 是 flexy-sandbox 的延伸版本，加入了瀏覽器自動化測試能力。透過整合 **Xvfb**、**Chromium**、**Playwright** 和 **VNC**，AI 模型可以在沙盒環境中進行前端 App 測試任務。

## 架構說明

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

## 運行模式

chromium-sandbox 支援三種運行模式：

| 模式 | 說明 | VNC | 用途 |
|------|------|-----|------|
| `headless` | 純無頭模式，Playwright 內建 | ❌ | 自動化測試、CI/CD |
| `xvfb` | 虛擬顯示，無遠端存取 | ❌ | 需要顯示環境的測試 |
| `vnc` | 完整 VNC + noVNC | ✅ | 可視化調試、開發 |

## 快速開始

### 1. 建置映像

```bash
cd chromium-sandbox
docker build -t chromium-sandbox .
```

### 2. 無頭模式 (預設)

最簡單的啟動方式：

```bash
docker run -it --rm \
  -v $(pwd):/home/flexy/workspace \
  chromium-sandbox
```

### 3. VNC 模式 (可視化調試)

啟動 VNC 服務，透過瀏覽器觀看測試過程：

```bash
docker run -it --rm \
  -e CHROMIUM_MODE=vnc \
  -p 6900:6900 \
  -v $(pwd):/home/flexy/workspace \
  chromium-sandbox
```

然後在瀏覽器開啟：**http://localhost:6900**

預設密碼：`dockerSandbox`

## 環境變數

### Chromium 模式設定

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `CHROMIUM_MODE` | `headless` | 運行模式: `headless` / `xvfb` / `vnc` |
| `CHROMIUM_DISPLAY` | `:99` | X11 顯示編號 |
| `CHROMIUM_RESOLUTION` | `1920x1080x24` | 虛擬顯示解析度 (寬x高x色深) |

### VNC 設定

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `VNC_PORT` | `5900` | VNC 伺服器端口 |
| `NOVNC_PORT` | `6900` | noVNC Web 客戶端端口 |
| `VNC_PASSWORD` | `dockerSandbox` | VNC 連線密碼 |

## Playwright 使用範例

### 基礎範例

```javascript
const { chromium } = require('playwright');

// 啟動瀏覽器
const browser = await chromium.launch({
  headless: process.env.CHROMIUM_MODE === 'headless'
});

// 建立新頁面
const page = await browser.newPage();

// 導航到網頁
await page.goto('https://example.com');

// 獲取標題
const title = await page.title();
console.log('Page title:', title);

// 截圖
await page.screenshot({ path: '/tmp/screenshot.png' });

// 關閉瀏覽器
await browser.close();
```

### 使用 AI Helper (推薦)

AI Helper 提供更簡潔的 API，適合 AI 模型使用：

```javascript
const { createHelper } = require('./examples/ai-playwright-helper.js');

const browser = createHelper();

await browser.launch();
await browser.goto('https://example.com');
await browser.title();
await browser.fill('input[name="q"]', 'Hello World');
await browser.click('button[type="submit"]');
await browser.screenshot('result');
await browser.close();
```

## 常見使用場景

### 場景 1: 網頁截圖

```javascript
const { chromium } = require('playwright');

const browser = await chromium.launch();
const page = await browser.newPage();

await page.goto('https://example.com');
await page.screenshot({
  path: '/tmp/screenshot.png',
  fullPage: true
});

await browser.close();
```

### 場景 2: 表單填寫與提交

```javascript
const { createHelper } = require('./examples/ai-playwright-helper.js');

const browser = createHelper();

await browser.launch();
await browser.goto('https://example.com/form');
await browser.fill('#name', 'John Doe');
await browser.fill('#email', 'john@example.com');
await browser.click('button[type="submit"]');
await browser.close();
```

### 場景 3: 網頁爬蟲

```javascript
const { chromium } = require('playwright');

const browser = await chromium.launch();
const page = await browser.newPage();

await page.goto('https://example.com');

// 提取所有連結
const links = await page.evaluate(() => {
  return Array.from(document.querySelectorAll('a'))
    .map(a => ({ text: a.textContent, href: a.href }));
});

console.log(links);

await browser.close();
```

### 場景 4: AI 模型執行測試

在 Claude Code 中執行：

```bash
# 啟動測試
claude "使用 Playwright 測試我的網站，訪問 http://localhost:3000 並截圖"
```

## 測試腳本

chromium-sandbox 提供內建的測試腳本：

```bash
# 測試 Chromium + Playwright 是否正常運作
./scripts/test-chromium.sh
```

測試內容包括：
- Xvfb 服務狀態 (非 headless 模式)
- Playwright 安裝狀態
- Chromium 瀏覽器安裝狀態
- 基礎瀏覽器操作測試

## VNC 使用說明

### 連線方式

1. 啟動容器（VNC 模式）：
```bash
docker run -it --rm \
  -e CHROMIUM_MODE=vnc \
  -p 6900:6900 \
  chromium-sandbox
```

2. 在瀏覽器開啟：http://localhost:6900

3. 輸入密碼：`dockerSandbox`

### VNC 操作

- **滑點左鍵**：點擊
- **滑點右鍵**：右鍵選單
- **Ctrl+Alt+Del**：傳送 Ctrl+Alt+Del
- **Fn+Ctrl**：傳送 Ctrl 鍵

## 故障排除

### 問題：Chromium 無法啟動

**症狀**：`Executable doesn't exist at /.../chromium`

**解決**：
```bash
npx playwright install chromium
```

### 問題：Xvfb 無法啟動

**症狀**：`Xvfb: failed to start`

**解決**：
```bash
# 檢查 Xvfb 進程
ps aux | grep Xvfb

# 檢查 DISPLAY 環境變數
echo $DISPLAY
```

### 問題：VNC 連線失敗

**症狀**：無法連線到 http://localhost:6900

**解決**：
1. 確認端口正確映射：`-p 6900:6900`
2. 確認 CHROMIUM_MODE 設為 `vnc`
3. 檢查容器日誌：`docker logs <container-id>`

## 效能建議

### 記憶體設定

Chromium 記憶體消耗較大，建議 Docker 容器至少分配：

| 場景 | 最低記憶體 | 建議記憶體 |
|------|-----------|-----------|
| headless 單頁面 | 512 MB | 1 GB |
| headless 多頁面 | 1 GB | 2 GB |
| VNC 模式 | 2 GB | 4 GB |

```bash
docker run -it --rm \
  --memory=2g \
  --memory-swap=2g \
  chromium-sandbox
```

### CPU 限制

如需限制 CPU 使用：

```bash
docker run -it --rm \
  --cpus=1.5 \
  chromium-sandbox
```

## 安全性建議

1. **修改 VNC 密碼**：生產環境請修改預設密碼
   ```bash
   -e VNC_PASSWORD=your_secure_password
   ```

2. **限制 VNC 存取**：不要在公網暴露 VNC 端口
   ```bash
   # 只允許本機存取
   -p 127.0.0.1:6900:6900
   ```

3. **使用 readonly 模式**：如只需觀看，不需操作
   ```bash
   x11vnc ... -readonly
   ```

## 參考資源

- [Playwright 官方文件](https://playwright.dev/)
- [noVNC GitHub](https://github.com/novnc/noVNC)
- [Xvfb 手冊](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)
