import { chromium, Browser, Page } from 'playwright';

export async function monitorRequests(
  url: string,
  timeoutMs = 5_000
): Promise<string[]> {
  let browser: Browser | null = null;

  try {
    browser = await chromium.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    });

    const context = await browser.newContext({
      userAgent:
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' +
        'AppleWebKit/537.36 (KHTML, like Gecko) ' +
        'Chrome/114.0.0.0 Safari/537.36',
      locale: 'cs-CZ',
    });

    await context.route('**/*.{png,jpg,jpeg,woff2,css,svg}', route => route.abort());

    const page: Page = await context.newPage();
    const seen = new Set<string>();
    page.on('request', req => seen.add(req.url()));

    await page.goto(url, { waitUntil: 'networkidle', timeout: 15_000 });
    await page.waitForTimeout(timeoutMs);

    return Array.from(seen);
  } finally {
    if (browser) await browser.close();
  }
}
