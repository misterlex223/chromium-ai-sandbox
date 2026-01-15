# Frontend Tester Plugin

AI 驅動的前端測試工程師 Plugin，根據產品規格自動執行測試並生成報告。

## 功能特色

- **規格驅動測試**: 根據 Markdown 格式的產品規格執行測試
- **混合測試模式**: 支援自動化測試和人工檢查
- **Playwright 整合**: 使用 Playwright MCP 執行瀏覽器自動化
- **測試報告**: 生成結構化的 Markdown 測試報告

## 安裝

此 Plugin 已內建於 Chromium AI Sandbox，無需額外安裝。

容器啟動時會自動安裝到：
```
/home/flexy/.claude/plugins/frontend-tester
```

### 安裝流程

1. **Dockerfile**: 複製 plugin 到 `/tmp/frontend-tester-plugin`
2. **init-chromium-sandbox.sh**: 安裝到 `/home/flexy/.claude/plugins/`

## 使用方式

### 1. 建立產品規格

使用範本建立規格文件：

```
/test-spec-template specs/login-spec.md
```

編輯規格文件，填寫測試場景和驗收標準。

### 2. 執行測試

根據規格執行測試：

```
/test-spec specs/login-spec.md
```

### 3. 查看報告

測試完成後，報告會生成在：

```
test-reports/test-report-[YYYY-MM-DD]-[feature-name].md
```

## 規格文件格式

規格文件使用 Markdown 格式，包含以下區塊：

```markdown
# 功能名稱

## 基本信息
- 功能名稱: [名稱]
- 測試 URL: [URL]
- 測試環境: [開發 | 預產 | 產品]

## 測試場景

### 場景 1: 正常登入
**類型**: 自動化

| 步驟 | 動作 | 預期結果 |
|------|------|---------|
| 1 | 導航到登入頁 | 頁面正常顯示 |
| 2 | 輸入有效帳號密碼 | 表單接受輸入 |
| 3 | 點擊提交 | 登入成功 |

## UI/UX 驗收標準
- [ ] 符合設計稿
- [ ] 響應式布局正常
- [ ] 可訪問性符合 WCAG AA
```

完整範本請參考 `templates/spec-template.md`。

## Plugin 結構

```
sandbox-plugins/frontend-tester/
├── .claude-plugin/
│   └── plugin.json           # Plugin 清單
├── agents/
│   └── frontend-test-engineer.md  # 測試工程師 Agent
├── commands/
│   ├── test-spec.md          # 執行測試命令
│   └── test-spec-template.md # 產生範本命令
├── templates/
│   └── spec-template.md      # 規格範本
├── skills/
│   └── frontend-testing/
│       └── SKILL.md          # 測試技能說明
└── README.md
```

## 可用功能

| 類型 | 名稱 | 說明 |
|------|------|------|
| **Agent** | `frontend-test-engineer` | 自動觸發測試工作流程 |
| **Command** | `/test-spec <file>` | 根據規格執行測試 |
| **Command** | `/test-spec-template [path]` | 產生規格範本 |
| **Skill** | `frontend-testing` | 測試最佳實踐 |

## 測試流程

```
┌─────────────┐
│ 1. 解析規格 │
└──────┬──────┘
       ▼
┌─────────────┐
│ 2. 建立計劃 │
└──────┬──────┘
       ▼
┌─────────────┐     ┌─────────────┐
│ 3a. 自動化  │     │ 3b. 人工    │
│    測試     │     │    檢查     │
└──────┬──────┘     └──────┬──────┘
       └─────┬────────────┘
             ▼
      ┌─────────────┐
      │ 4. 生成報告 │
      └─────────────┘
```

## 環境需求

- Chromium AI Sandbox
- Claude Code with MCP support
- Playwright MCP Server (`@playwright/mcp`)
- Node.js 18+

## 授權

MIT License
