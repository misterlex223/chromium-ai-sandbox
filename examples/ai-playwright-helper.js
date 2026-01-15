/**
 * AI Playwright Helper - AI 友好的 Playwright 包裝層
 *
 * 提供簡化的 API 讓 AI 模型容易執行常見的瀏覽器操作
 *
 * 設計理念：
 * - 簡單的函數命名，讓 AI 容易理解
 * - 自動等待和錯誤處理
 * - 自動截圖除錯
 *
 * 執行方式:
 *   node examples/ai-playwright-helper.js
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

// 截圖目錄
const SCREENSHOT_DIR = '/tmp/playwright-screenshots';
if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

/**
 * AI Browser Helper 類別
 */
class AIBrowserHelper {
  constructor(options = {}) {
    this.options = {
      headless: (process.env.CHROMIUM_MODE || 'headless') === 'headless',
      viewport: { width: 1920, height: 1080 },
      slowMo: options.slowMo || 50, // 放慢操作，方便觀察
      screenshotDir: SCREENSHOT_DIR,
      ...options
    };
    this.browser = null;
    this.context = null;
    this.page = null;
    this.screenshotIndex = 0;
  }

  /**
   * 啟動瀏覽器
   */
  async launch() {
    console.log('🚀 Launching browser...');
    this.browser = await chromium.launch({
      headless: this.options.headless,
      slowMo: this.options.slowMo,
    });
    this.context = await this.browser.newContext({
      viewport: this.options.viewport,
    });
    this.page = await this.context.newPage();
    console.log('✓ Browser launched');
    return this;
  }

  /**
   * 導航到指定 URL
   */
  async goto(url) {
    console.log(`📍 Navigating to: ${url}`);
    await this.page.goto(url, { waitUntil: 'networkidle' });
    await this.screenshot('navigate');
    return this;
  }

  /**
   * 填寫輸入框
   */
  async fill(selector, value) {
    console.log(`✍️  Filling "${selector}" with: "${value}"`);
    await this.page.fill(selector, value);
    await this.screenshot(`fill-${selector.replace(/[^a-zA-Z0-9]/g, '_')}`);
    return this;
  }

  /**
   * 點擊元素
   */
  async click(selector) {
    console.log(`🖱️  Clicking: "${selector}"`);
    await this.page.click(selector);
    await this.page.waitForTimeout(500); // 等待反應
    await this.screenshot(`click-${selector.replace(/[^a-zA-Z0-9]/g, '_')}`);
    return this;
  }

  /**
   * 獲取元素文字
   */
  async text(selector) {
    const element = this.page.locator(selector).first();
    const text = await element.textContent();
    console.log(`📝 Text from "${selector}": "${text}"`);
    return text;
  }

  /**
   * 獲取頁面標題
   */
  async title() {
    const title = await this.page.title();
    console.log(`📄 Page title: "${title}"`);
    return title;
  }

  /**
   * 獲取頁面 URL
   */
  async url() {
    const url = this.page.url();
    console.log(`🔗 Current URL: "${url}"`);
    return url;
  }

  /**
   * 等待元素出現
   */
  async waitFor(selector, timeout = 5000) {
    console.log(`⏳ Waiting for: "${selector}"`);
    await this.page.waitForSelector(selector, { timeout });
    console.log(`✓ Element found: "${selector}"`);
    return this;
  }

  /**
   * 執行 JavaScript
   */
  async evaluate(script) {
    const result = await this.page.evaluate(script);
    console.log(`🔧 Executed JS, result:`, result);
    return result;
  }

  /**
   * 截圖
   */
  async screenshot(label = 'screenshot') {
    this.screenshotIndex++;
    const filename = `${String(this.screenshotIndex).padStart(3, '0')}-${label}.png`;
    const filepath = path.join(this.options.screenshotDir, filename);
    await this.page.screenshot({ path: filepath, fullPage: false });
    console.log(`📸 Screenshot saved: ${filepath}`);
    return filepath;
  }

  /**
   * 滾動到頁面底部
   */
  async scrollToBottom() {
    console.log('⬇️  Scrolling to bottom...');
    await this.page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    await this.page.waitForTimeout(500);
    await this.screenshot('scroll-bottom');
    return this;
  }

  /**
   * 搜尋 (通用搜尋函數)
   */
  async search(query, searchInputSelector = 'input[name="q"], input[type="search"], #search, .search-input') {
    console.log(`🔍 Searching for: "${query}"`);
    await this.page.fill(searchInputSelector, query);
    await this.page.press(searchInputSelector, 'Enter');
    await this.page.waitForLoadState('networkidle');
    await this.screenshot(`search-${query.replace(/[^a-zA-Z0-9]/g, '_')}`);
    return this;
  }

  /**
   * 提取頁面內容摘要
   */
  async summarize() {
    const summary = await this.page.evaluate(() => {
      return {
        title: document.title,
        url: window.location.href,
        h1: Array.from(document.querySelectorAll('h1')).map(h => h.textContent.trim()),
        links: document.querySelectorAll('a').length,
        forms: document.querySelectorAll('form').length,
      };
    });
    console.log('📊 Page summary:', summary);
    return summary;
  }

  /**
   * 關閉瀏覽器
   */
  async close() {
    console.log('🔒 Closing browser...');
    if (this.page) await this.page.close();
    if (this.context) await this.context.close();
    if (this.browser) await this.browser.close();
    console.log('✓ Browser closed');
  }
}

/**
 * 創建 AI Browser Helper 實例
 */
function createHelper(options = {}) {
  return new AIBrowserHelper(options);
}

// 如果直接執行此檔案，運行範例測試
if (require.main === module) {
  (async () => {
    const helper = createHelper();

    try {
      // 範例：維基百科搜尋
      await helper.launch();
      await helper.goto('https://www.wikipedia.org');
      await helper.title();
      await helper.fill('#searchInput', 'Artificial Intelligence');
      await helper.click('button[type="submit"], .search-button');
      await helper.screenshot('wiki-result');
      await helper.summarize();
      await helper.close();

      console.log('\n✅ Test completed successfully!');
      console.log(`📸 Screenshots saved to: ${SCREENSHOT_DIR}`);
    } catch (error) {
      console.error('❌ Test failed:', error);
      await helper.close();
      process.exit(1);
    }
  })();
}

module.exports = { AIBrowserHelper, createHelper };
