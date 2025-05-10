// Purpose: Scan HTML content for known tracking script patterns.

const TRACKER_PATTERNS: { name: string; regex: RegExp }[] = [
    { name: 'Google Analytics 4', regex: /gtag\(\'config\',\s*\'G-/i },
    { name: 'Facebook Pixel',    regex: /fbq\('init',\s*'\d+'?\)/i },
    { name: 'Sklik',              regex: /cm\.sclk\(/i },
    { name: 'Microsoft Ads',      regex: /bing\.com\/bidscript\.js/i },
  ];
  
  /**
   * @param html The raw HTML string of the page.
   * @returns An array of tracker names that were found.
   */
  export function detectTrackers(html: string): string[] {
    const found: string[] = [];
  
    for (const tracker of TRACKER_PATTERNS) {
      if (tracker.regex.test(html)) {
        found.push(tracker.name);
      }
    }
  
    return found;
  }
  