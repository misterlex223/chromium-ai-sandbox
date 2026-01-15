/**
 * Playwright Example - 基礎瀏覽器測試範例
 *
 * 展示如何在 chromium-sandbox 中使用 Playwright 進行瀏覽器測試
 *
 * 執行方式:
 *   node examples/playwright-example.js
 */

const { chromium } = require('playwright');

async function main() {
  console.log('Starting Playwright test...');
  console.log('Mode:', process.env.CHROMIUM_MODE || 'headless');
  console.log('Display:', process.env.DISPLAY || 'N/A');

  // 啟動 Chromium
  // headless: 根據 CHROMIUM_MODE 環境變數決定
  const headless = (process.env.CHROMIUM_MODE || 'headless') === 'headless';

  const browser = await chromium.launch({
    headless: headless,
    args: headless ? [] : [`--display=${process.env.CHROMIUM_DISPLAY || ':99'}`]
  });

  console.log('Browser launched');

  // 建立新頁面
  const page = await browser.newPage();

  // 設定視口大小
  await page.setViewportSize({ width: 1920, height: 1080 });

  // 導航到網頁
  console.log('Navigating to example.com...');
  await page.goto('https://example.com');

  // 等待頁面載入
  await page.waitForLoadState('networkidle');

  // 獲取頁面標題
  const title = await page.title();
  console.log('Page title:', title);

  // 獲取頁面內容
  const h1Text = await page.locator('h1').textContent();
  console.log('H1 text:', h1Text);

  // 截圖 (在 VNC 模式下可以觀看到)
  const screenshotPath = '/tmp/example-screenshot.png';
  await page.screenshot({ path: screenshotPath });
  console.log('Screenshot saved to:', screenshotPath);

  // 執行 JavaScript
  const domain = await page.evaluate(() => window.location.hostname);
  console.log('Current domain:', domain);

  // 測試表單互動 (以 wikipedia 為例)
  console.log('Testing form interaction...');
  await page.goto('https://www.wikipedia.org');
  await page.fill('#searchInput', 'Playwright automation');
  await page.screenshot({ path: '/tmp/wikipedia-screenshot.png' });
  console.log('Form interaction test complete');

  // 關閉瀏覽器
  await browser.close();
  console.log('Test completed successfully!');
}

// 執行測試
main().catch(err => {
  console.error('Test failed:', err);
  process.exit(1);
});
