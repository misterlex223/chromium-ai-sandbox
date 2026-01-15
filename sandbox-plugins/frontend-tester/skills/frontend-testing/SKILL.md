---
name: frontend-testing
description: Use this skill when testing frontend applications, validating UI against specifications, running Playwright tests, or generating test reports. Trigger when user mentions "test", "validate", "verify", "check spec", or describes frontend quality assurance tasks.
version: 1.0.0
---

# Frontend Testing Skill

前端測試技能，提供完整的測試流程和最佳實踐。

## 何時使用

當用戶提出以下需求時使用此技能：

- "測試這個功能"
- "驗證是否符合規格"
- "產生測試報告"
- "檢查 UI 問題"
- "執行 E2E 測試"

## 測試類型

### 1. 功能測試

驗證功能是否符合需求規格。

**關鍵點**:
- 正常流程是否通暢
- 錯誤處理是否正確
- 邊界條件是否考慮

### 2. UI/UX 測試

驗證使用者介面體驗。

**檢查項目**:
- 視覺設計符合度
- 響應式布局
- 互動狀態 (hover, focus, active, disabled)
- 動畫效果

### 3. 可訪問性測試

確保所有用戶都能使用。

**檢查項目**:
- 鍵盤導航
- Screen reader 支援
- 顏色對比度 (WCAG AA: 4.5:1)
- ARIA 標籤正確性

### 4. 效能測試

確保應用程式效能良好。

**指標**:
- 頁面載入時間 < 3s
- First Contentful Paint < 1.5s
- Time to Interactive < 3s
- 動畫幀率 ≥ 60fps

## Playwright 測試範例

### 基本測試

```javascript
// 導航並截圖
await page.goto('https://example.com');
await page.screenshot({ path: 'home.png' });

// 填寫表單
await page.fill('[name="email"]', 'user@example.com');
await page.fill('[name="password"]', 'password123');
await page.click('button[type="submit"]');

// 驗證結果
await expect(page).toHaveURL(/dashboard/);
await expect(page.locator('.welcome')).toBeVisible();
```

### 等待策略

```javascript
// 等待元素出現
await page.waitForSelector('.success-message');

// 等待導航完成
await page.waitForURL(/dashboard/);

// 等待網路請求
await page.waitForResponse('**/api/login');
```

### 處理動態內容

```javascript
// 等待載入狀態
await page.waitForSelector('.loading', { state: 'hidden' });

// 處理 modal
await page.click('.open-modal');
await expect(page.locator('.modal')).toBeVisible();
```

## 測試報告格式

### 結構

```markdown
# 測試報告 - [功能名稱]

## 摘要
- 測試日期: [日期]
- 測試人員: [名稱]
- 測試環境: [環境]

## 統計
- 總測試數: N
- 通過: N
- 失敗: N
- 通過率: N%

## 詳細結果
[各測試場景的詳細結果]

## 問題清單
[發現的問題]

## 建議
[改進建議]
```

### 嚴重度分級

| 等級 | 標記 | 說明 |
|------|------|------|
| 嚴重 | 🔴 High | 阻礙核心功能 |
| 中等 | 🟡 Medium | 影響用戶體驗 |
| 輕微 | 🟢 Low | 非關鍵問題 |

## 最佳實踐

### 1. 測試組織

```
test-reports/
├── [feature-name]/
│   ├── test-report.md
│   ├── screenshots/
│   │   ├── scene-1.png
│   │   └── scene-2.png
│   └── logs/
│       └── test.log
```

### 2. 命名慣例

- 規格文件: `[feature]-spec.md`
- 測試報告: `test-report-[YYYY-MM-DD]-[feature].md`
- 截圖: `scene-[N]-[description].png`

### 3. 測試原則

- **獨立性**: 每個測試應該獨立執行
- **可重複**: 測試結果應該一致
- **清晰**: 測試名稱和步驟應該清楚表達意圖
- **快速**: 優先測試重要功能

## 常見問題

### Q: 如何測試需要登入的功能？

A: 使用環境變數或測試帳號：

```javascript
await page.fill('[name="email"]', process.env.TEST_USER);
await page.fill('[name="password"]', process.env.TEST_PASS);
await page.click('[type="submit"]');
```

### Q: 如何處理測試資料？

A: 每次測試前重置資料，或使用固定測試資料。

### Q: 測試不穩定怎麼辦？

A: 檢查等待策略，避免硬编码延遲：

```javascript
// ❌ 不好
await page.waitForTimeout(5000);

// ✅ 好
await page.waitForSelector('.result');
```

## 相關資源

- [Playwright 文檔](https://playwright.dev)
- [WCAG 2.1 標準](https://www.w3.org/WAI/WCAG21/quickref/)
- [測試範本](../templates/spec-template.md)
