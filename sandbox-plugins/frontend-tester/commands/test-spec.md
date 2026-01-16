---
description: 執行前端測試，根據產品規格驗證功能
argument-hint: <spec-file-path>
allowed-tools: ["Read", "Write", "Bash", "Grep", "Glob", "TodoWrite"]
---

# /test-spec - 前端測試命令

根據指定的產品規格文件執行前端測試。

## 用法

```
/test-spec <spec-file-path>
```

## 參數

- `spec-file-path`: 產品規格文件路徑 (必填)
  - 支援相對路徑或絕對路徑
  - 檔案格式必須符合規格範本

## 執行步驟

### 1. 驗證規格文件

```
檢查 @$1 是否存在且格式正確
```

如果文件不存在：
```
❌ 錯誤: 找不到規格文件 @$1

提示:
- 確認檔案路徑正確
- 使用 /test-spec-template 來建立規格範本
```

### 2. 解析測試場景

從規格文件中提取：
- 自動化測試場景
- 人工檢查項目
- 測試 URL 和環境資訊
- 驗收標準

### 3. 建立測試計劃

使用 TodoWrite 建立測試任務清單：

```
✅ 解析規格文件: @$1
⏳ 執行自動化測試 (N 個場景)
⏳ 執行人工檢查 (N 個項目)
⏳ 生成測試報告
```

### 4. 執行測試

#### 自動化測試

對於標記為「自動化」的場景，使用 Playwright MCP 執行：

```
1. launch_browser
2. navigate_to [URL]
3. [執行測試步驟]
4. screenshot
5. **檢查 browser_console_messages**
6. 驗證結果
```

**Console 檢查步驟** (每個測試場景必須執行):

```
使用 browser_console_messages 工具獲取 console 訊息
- level="error" - 檢查錯誤訊息
- level="warning" - 檢查警告訊息

如果有錯誤:
  - 測試結果標記為「失敗」
  - 記錄錯誤訊息內容
  - 記錄錯誤來源 (檔案:行號)

如果有警告:
  - 測試結果標記為「警告」
  - 記錄警告訊息內容
```

#### 人工檢查

對於標記為「人工檢查」的項目，產生檢查清單：

```
請人工驗證以下項目:
- [ ] 項目 1
- [ ] 項目 2
```

### 5. 生成報告

測試完成後，產生 Markdown 報告：

```
📄 測試報告: test-reports/test-report-[timestamp].md
```

**報告必須包含**:
- Console 錯誤摘要 (錯誤數量、警告數量)
- 每個失敗測試的 console 錯誤訊息
- 錯誤來源 (檔案名稱和行號)

## 範例

### 範例 1: 測試登入功能

```
/test-spec docs/login-spec.md
```

輸出：
```
✅ 找到規格文件: docs/login-spec.md
✅ 解析測試場景: 5 個
- 自動化測試: 3 個
- 人工檢查: 2 個

⏳ 開始執行測試...
✅ 場景 1: 正常登入 | Console: 無錯誤
✅ 場景 2: 無效電子郵件 | Console: 無錯誤
❌ 場景 3: 錯誤密碼 | Console: 1 個錯誤
   🔴 Error: "UnauthorizedError: Invalid credentials" (api.js:25)
⏳ 場景 4: 視覺檢查 (需人工驗證)

📊 測試完成: 2/3 通過
📋 Console 摘要: 1 錯誤, 0 警告
📄 報告已生成: test-reports/test-report-2025-01-15-login.md
```

### 範例 2: 測試用戶註冊

```
/test-spec specs/registration.md
```

## 錯誤處理

| 錯誤 | 處理方式 |
|------|---------|
| 規格文件不存在 | 顯示錯誤並提示使用範本 |
| 規格格式錯誤 | 指出錯誤位置並提供修正建議 |
| Playwright 未啟動 | 提示啟動 MCP Server |
| 測試 URL 無法訪問 | 記錄錯誤並繼續其他測試 |
| **Console 發現錯誤** | **測試標記失敗，記錄錯誤訊息和來源** |
| **Console 發現警告** | **測試標記警告，記錄警告訊息** |

## 相關命令

- `/test-spec-template` - 產生規格範本
- `/test-report` - 查看最近的測試報告
