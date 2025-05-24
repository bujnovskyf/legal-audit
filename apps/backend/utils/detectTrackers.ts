import { monitorRequests } from './monitorRequests';
import type { TrackerInfo } from '../types/types';

interface StaticPattern {
  name: string;
  regex: RegExp;
}

const HTML_PATTERNS: StaticPattern[] = [
  { name: 'Google Analytics 4', regex: /gtag\(\s*['"]config['"],\s*['"]G-/i },
  { name: 'Google Ads Remarketing', regex: /googletagmanager\.com\/gtag\/js|googleads\.g\.doubleclick\.net|(?:google\.com|googlesyndication\.com)\/ccm\/collect/i },
  { name: 'Facebook Pixel', regex: /fbq\(\s*['"]init['"],\s*'\d+'|connect\.facebook\.net\/.*\/fbevents\.js|connect\.facebook\.net\/signals\/config\//i },
  { name: 'Sklik Remarketing', regex: /(?:[acm]\.)?seznam\.cz\/retargeting|cm\.sklik\.cz|bs\.serving-sys\.com\/BurstingPipe/i },
  { name: 'Microsoft Ads Remarketing', regex: /bat\.bing\.com\/action/i },
  { name: 'Microsoft Clarity', regex: /clarity\.ms\/tag\/[A-Za-z0-9]+/i },
  { name: 'Hotjar', regex: /static\.hotjar\.com\/c\/hotjar-/i },
  { name: 'TikTok Pixel', regex: /analytics\.tiktok\.com\/i18n\/pixel|ttq\.load\(/i },
  { name: 'LinkedIn Insight Tag', regex: /px\.ads\.linkedin\.com\/collect/i },
  { name: 'X (Twitter) Pixel', regex: /analytics\.twitter\.com\/i\/adsct/i },
];

const PIXEL_TRACKERS = [
  'Facebook Pixel',
  'Hotjar',
  'TikTok Pixel',
  'LinkedIn Insight Tag',
  'X (Twitter) Pixel',
  'Microsoft Clarity',
];

function extractParam(reqUrl: string, paramName: string): string | null {
  try {
    const url = new URL(reqUrl, 'http://dummybase.cz');
    return url.searchParams.get(paramName);
  } catch (_) {
    const regex = new RegExp(`[?&]${paramName}=([^&#]*)`);
    const match = reqUrl.match(regex);
    return match ? match[1] : null;
  }
}

export async function detectTrackers(html: string, url: string): Promise<TrackerInfo[]> {
  const found = new Map<string, TrackerInfo>();
  for (const { name, regex } of HTML_PATTERNS) {
    if (regex.test(html)) {
      found.set(name, { name, consent: 'none' });
    }
  }

  const eventSeen = PIXEL_TRACKERS.reduce<Record<string, boolean>>((acc, name) => {
    acc[name] = false;
    return acc;
  }, {});

  let requests: string[] = [];
  try {
    requests = await monitorRequests(url);
  } catch (e) {
    console.error('monitorRequests failed, skipping dynamic scan:', e);
  }

  for (const reqUrl of requests) {
    let tracker: string | undefined;
    let consentValue: boolean | 'none' | undefined;

    if (/google-analytics\.com\/g\/collect|google-analytics\.com\/collect|gtag\/js/.test(reqUrl)) {
      tracker = 'Google Analytics 4';
    } else if (/(?:google\.com|googlesyndication\.com)\/ccm\/collect|googletagservices\.com\/tag\/js|googleads\.g\.doubleclick\.net/.test(reqUrl)) {
      tracker = 'Google Ads Remarketing';
    } else if (/facebook\.com\/tr\/\?/.test(reqUrl) || /facebook\.com\/privacy_sandbox\/pixel\/register\/trigger/.test(reqUrl)) {
      tracker = 'Facebook Pixel';
      eventSeen['Facebook Pixel'] = true;
    } else if (/(?:[acm]\.)?seznam\.cz\/retargeting|cm\.sklik\.cz|bs\.serving-sys\.com\/BurstingPipe/i.test(reqUrl)) {
      tracker = 'Sklik Remarketing';

      const consentParam = extractParam(reqUrl, 'consent');
      if (consentParam !== null) {
        consentValue = consentParam === '1';
      } else {
        consentValue = 'none';
      }
    } else if (/bat\.bing\.com\/action/.test(reqUrl)) {
      tracker = 'Microsoft Ads Remarketing';
      const asc = extractParam(reqUrl, 'asc');
      if (asc === 'G') consentValue = true;
      else if (asc === 'D') consentValue = false;
    } else if (/clarity\.ms\//.test(reqUrl)) {
      tracker = 'Microsoft Clarity';
      eventSeen['Microsoft Clarity'] = true;
    } else if (/static\.hotjar\.com\/c\/hotjar-/.test(reqUrl)) {
      tracker = 'Hotjar';
      eventSeen['Hotjar'] = true;
    } else if (/analytics\.tiktok\.com\/i18n\/pixel|ttq\.load\(/.test(reqUrl)) {
      tracker = 'TikTok Pixel';
      eventSeen['TikTok Pixel'] = true;
    } else if (/px\.ads\.linkedin\.com\/collect/.test(reqUrl)) {
      tracker = 'LinkedIn Insight Tag';
      eventSeen['LinkedIn Insight Tag'] = true;
    } else if (/analytics\.twitter\.com\/i\/adsct/.test(reqUrl)) {
      tracker = 'X (Twitter) Pixel';
      eventSeen['X (Twitter) Pixel'] = true;
    }

    if (!tracker) continue;

    if (tracker === 'Google Analytics 4' || tracker === 'Google Ads Remarketing') {
      const raw = extractParam(reqUrl, 'gcs');
      if (tracker === 'Google Ads Remarketing') {
        if (raw && raw.length >= 4) {
          if (raw[1] === '1') {
            const npa = extractParam(reqUrl, 'npa');
            consentValue = npa === '0';
          } else {
            consentValue = false;
          }
        } else {
          consentValue = true;
        }
      } else {
        if (raw && raw.length >= 4) {
          consentValue = raw[2] === '1';
        } else {
          consentValue = true;
        }
      }
    }

    const prev = found.get(tracker);
    if (prev) {
      if (consentValue !== undefined) {
        prev.consent = consentValue;
      }
    } else {
      found.set(tracker, { name: tracker, consent: consentValue ?? 'none' });
    }
  }

  for (const name of PIXEL_TRACKERS) {
    if (found.has(name)) {
      found.get(name)!.consent = eventSeen[name];
    }
  }

  return Array.from(found.values());
}
