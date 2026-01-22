# Chromium AI Sandbox Skills

這份文件描述 Chromium AI Sandbox 的功能，讓 Claude Code 能夠有效使用沙盒中的工具。

## 沙盒概述

**Chromium AI Sandbox** 是一個專為 AI Agent 設計的瀏覽器自動化沙盒環境，整合了：
- Chromium 瀏覽器
- Playwright 自動化框架
- Xvfb 虛擬顯示
- VNC/noVNC 遠端查看
- **Frontend Tester Plugin**（含 Microsoft Playwright MCP Server）

> **注意**: Playwright MCP Server 透過 `frontend-tester` plugin 提供，該 plugin 從 `aintandem-agent-team` marketplace 自動安裝。

## 核心能力

### 1. MCP 瀏覽器自動化（推薦）

沙盒內建 **Microsoft Playwright MCP Server**，Claude Code 可以直接呼叫以下工具，無需撰寫程式碼：

#### 可用工具

| 工具 | 用途 | 參數 |
|------|------|------|
| `launch_browser` | 啟動瀏覽器 | `headless`: boolean |
| `close_browser` | 關閉瀏覽器 | - |
| `navigate_to` | 導航到 URL | `url`: string |
| `screenshot` | 截圖 | `path`: string (選填) |
| `click` | 點擊元素 | `selector`: string |
| `fill` | 填寫輸入框 | `selector`: string, `value`: string |
| `select` | 選擇下拉選項 | `selector`: string, `value`: string |
| `hover` | 滑鼠懸停 | `selector`: string |
| `get_text` | 獲取元素文字 | `selector`: string |
| `get_url` | 獲取當前 URL | - |
| `go_back` | 返回上一頁 | - |
| `go_forward` | 前往下一頁 | - |
| `evaluate` | 執行 JavaScript | `script`: string |

#### 使用範例

```
User: "幫我訪問 https://example.com 並截圖"
Claude: [呼叫 launch_browser] -> [呼叫 navigate_to] -> [呼叫 screenshot]

User: "測試登入功能：帳號 test@example.com，密碼 pass123"
Claude: [呼叫 launch_browser] -> [呼叫 navigate_to] -> [呼叫 fill 填帳號] -> [呼叫 fill 填密碼] -> [呼叫 click 登入按鈕]

User: "抓取這個頁面所有 h1 標題"
Claude: [呼叫 launch_browser] -> [呼叫 navigate_to] -> [呼叫 evaluate 執行 JS 查詢 h1]
```

### 2. Playwright 直接程式設計

如果需要更複雜的操作，可以直接使用 Playwright API：

```javascript
const { chromium } = require('playwright');

// 啟動瀏覽器（根據 CHROMIUM_MODE 決定是否無頭）
const browser = await chromium.launch({
  headless: process.env.CHROMIUM_MODE === 'headless'
});

// 建立頁面和操作
const page = await browser.newPage();
await page.goto('https://example.com');
await page.screenshot({ path: '/tmp/screenshot.png' });

// 關閉瀏覽器
await browser.close();
```

### 3. VNC 可視化調試

當 `CHROMIUM_MODE=vnc` 時，可以透過 noVNC 查看瀏覽器操作：

- **URL**: http://localhost:6900/vnc.html
- **用途**: 實時查看 AI 操作瀏覽器的過程
- **密碼**: 無（開發模式）

## 環境變數

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `CHROMIUM_MODE` | `headless` | `headless` / `xvfb` / `vnc` |
| `CHROMIUM_DISPLAY` | `:99` | X11 顯示編號 |
| `CHROMIUM_RESOLUTION` | `1920x1080x24` | 虛擬顯示解析度 |
| `NOVNC_PORT` | `6900` | noVNC Web 端口 |

## 範例程式

沙盒內建有幾個範例程式供參考：

| 程式 | 路徑 | 說明 |
|------|------|------|
| Playwright 基礎範例 | `/home/flexy/examples/playwright-example.js` | 基本 Playwright 操作 |
| AI Helper | `/home/flexy/examples/ai-playwright-helper.js` | 簡化的 API 包裝層 |
| 保持開啟 | `/home/flexy/examples/keep-open.js` | 用於 VNC 調試 |

## 最佳實踐

### 1. 優先使用 MCP 工具

對於常見的瀏覽器操作，優先使用 MCP 工具而不是撰寫程式碼：
- ✅ "幫我訪問這個網站並截圖"（使用 MCP）
- ❌ "寫一段 Playwright 程式碼來訪問網站"（除非需要客製邏輯）

### 2. VNC 模式用於除錯

當操作失敗或需要驗證時，建議：
- 重啟容器並設定 `CHROMIUM_MODE=vnc`
- 透過 noVNC 觀察實際操作過程
- 截圖保存錯誤狀態

### 3. 截圖驗證

在關鍵操作後截圖，確保操作正確執行：
- 導航後截圖
- 表單填寫後截圖
- 點擊按鈕後截圖

### 4. 等待與重試

網頁載入需要時間，使用適當的等待策略：
- 使用 Playwright 的 `waitForLoadState('networkidle')`
- 使用 `waitForSelector` 等待特定元素出現
- 截圖前確保頁面已完全載入

## 測試工具

沙盒內建測試腳本：

```bash
# 測試 Chromium 和 Playwright 是否正常
/home/flexy/scripts/test-chromium.sh
```

## 故障排除

### 瀏覽器無法啟動
- 檢查 `CHROMIUM_MODE` 設定
- 確認 Xvfb 服務正在運行（非 headless 模式）
- 查看錯誤訊息並截圖

### MCP 工具無回應
- 確認 `frontend-tester` plugin 已正確安裝：`claude plugin list`
- 確認 `aintandem-agent-team` marketplace 已新增：`claude plugin marketplace list`
- 檢查 wrapper script 存在：`ls -la /usr/local/bin/playwright-mcp-wrapper.sh`
- 重新啟動 Claude Code

### VNC 連線失敗
- 確認端口映射正確 (`-p 6900:6900`)
- 確認 `CHROMIUM_MODE=vnc`
- 等待服務完全啟動（約 5 秒）

## 相關文件

- [Chromium 使用指南](/home/flexy/docs/CHROMIUM-GUIDE.md)
- [Playwright 官方文件](https://playwright.dev/)
- [Microsoft Playwright MCP](https://github.com/microsoft/playwright-mcp)
