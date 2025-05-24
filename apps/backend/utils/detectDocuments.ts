import axios from 'axios';
import { JSDOM } from 'jsdom';
import { analyzeDocument } from './analyzeDocuments';

const KEYWORDS = [
  // English
  'privacy', 'gdpr', 'personal-data', 'data-protection',
  'cookie', 'cookies', 'terms', 'conditions',
  'terms-of-service', 'terms-of-use',
  // Czech
  'ochrana-osobnich-udaju', 'zasady-ochrany-osobnich-udaju', 'osobni-udaje',
  'cookies', 'zasady-cookies', 'pouzivani-cookies',
  'obchodni-podminky', 'vseobecne-obchodni-podminky',
  'podminky-pouziti', 'podminky-sluzby', 'ochrany-osobnich-udaju',
];

function isRelevantLink(href: string): boolean {
  return KEYWORDS.some(keyword => href.toLowerCase().includes(keyword));
}

function guessDocType(url: string): string {
  const u = url.toLowerCase();
  if (u.includes('privacy') || u.includes('osobni')) return 'Privacy Policy';
  if (u.includes('cookie')) return 'Cookie Policy';
  if (u.includes('terms') || u.includes('obchodni') || u.includes('pouziti')) return 'Terms of Use';
  return 'Other';
}

interface DetectedDoc {
  url: string;
  type: string;
  summary?: string;
}

export async function detectDocuments(
  targetUrl: string,
  options?: { analyze?: boolean }
): Promise<DetectedDoc[]> {
  const analyze = options?.analyze ?? false;

  try {
    const response = await axios.get(targetUrl);
    const dom = new JSDOM(response.data);
    const document = dom.window.document;

    const links = Array.from(document.querySelectorAll('a'));
    const documentUrls: Set<string> = new Set();

    for (const link of links) {
      const href = link.getAttribute('href');
      if (href && isRelevantLink(href)) {
        try {
          const absoluteUrl = new URL(href, targetUrl).href;
          documentUrls.add(absoluteUrl);
        } catch (e) {
        }
      }
    }

    const results: DetectedDoc[] = [];

    for (const docUrl of documentUrls) {
      const docType = guessDocType(docUrl);

      if (analyze) {
        try {
          const summary = await analyzeDocument(docUrl);
          results.push({ url: docUrl, type: docType, summary });
        } catch (err: any) {
          results.push({ url: docUrl, type: docType, summary: '[ANALYSIS FAILED]' });
        }
      } else {
        results.push({ url: docUrl, type: docType });
      }
    }

    return results;

  } catch (err: any) {
    throw new Error('Failed to detect or analyze documents.');
  }
}
