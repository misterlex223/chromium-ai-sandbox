/**
 * Keep Browser Open - 讓瀏覽器保持開啟的測試腳本
 *
 * 用於在 VNC 模式下查看瀏覽器運行效果
 * 瀏覽器將保持開啟直到按下 Ctrl+C
 */

const { chromium } = require('playwright');

async function main() {
  console.log('========================================');
  console.log('  Launching Chromium (GUI mode)');
  console.log('========================================');
  console.log('DISPLAY:', process.env.DISPLAY || ':99');
  console.log('VNC URL: http://localhost:6900/vnc.html');
  console.log('========================================');

  const browser = await chromium.launch({
    headless: false,  // GUI 模式
    args: [`--display=${process.env.DISPLAY || ':99'}`]
  });

  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 }
  });

  const page = await context.newPage();

  // 導航到 Wikipedia
  console.log('Navigating to Wikipedia...');
  await page.goto('https://www.wikipedia.org');

  // 等待頁面載入
  await page.waitForLoadState('networkidle');

  console.log('✓ Page loaded!');
  console.log('✓ Browser is now visible in VNC');
  console.log('');
  console.log('Press Ctrl+C to close the browser...');

  // 保持開啟直到被中斷
  await new Promise(() => {
    // 這個 Promise 永遠不會 resolve，直到進程被殺死
  });

  await browser.close();
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
