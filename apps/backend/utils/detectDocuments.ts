import axios from 'axios';
import { JSDOM } from 'jsdom';

const GROG_API_KEY = process.env.GROG_API_KEY;
const GROG_API_URL = 'https://api.x.ai/v1/chat/completions';
const GROG_MODEL = 'grok-3-mini-latest';

if (!GROG_API_KEY) {
  throw new Error('GROG_API_KEY is missing in the environment.');
}

const KEYWORDS = [
  // English
  'privacy', 'gdpr', 'personal-data', 'data-protection',
  'cookie', 'cookies', 'terms', 'conditions',
  'terms-of-service', 'terms-of-use',
  // Czech
  'ochrana-osobnich-udaju', 'zasady-ochrany-osobnich-udaju', 'osobni-udaje',
  'cookies', 'zasady-cookies', 'pouzivani-cookies',
  'obchodni-podminky', 'vseobecne-obchodni-podminky',
  'podminky-pouziti', 'podminky-sluzby'
];

function isRelevantLink(href: string): boolean {
  return KEYWORDS.some(keyword => href.toLowerCase().includes(keyword));
}

export async function detectDocuments(targetUrl: string): Promise<any[]> {
  try {
    console.log(`[detectDocuments] Crawling URL: ${targetUrl}`);
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
          console.log(`[detectDocuments] Found relevant link: ${absoluteUrl}`);
        } catch (e) {
          console.warn(`[detectDocuments] Ignoring invalid URL in href: "${href}" - error: ${e}`);
        }
      }
    }

    const summaries: any[] = [];

    for (const docUrl of documentUrls) {
      try {
        console.log(`[detectDocuments] Analyzing document: ${docUrl}`);
        const summary = await analyzeDocument(docUrl);
        summaries.push({ url: docUrl, summary });
      } catch (err: any) {
        console.warn(`[detectDocuments] Failed to analyze ${docUrl}:`, err.message || err);
      }
    }

    console.log(`[detectDocuments] Completed summaries for ${summaries.length} documents.`);
    return summaries;

  } catch (err: any) {
    console.error('[detectDocuments] Error:', err.message);
    throw new Error('Failed to detect or analyze documents.');
  }
}


async function analyzeDocument(docUrl: string): Promise<string> {
  try {
    console.log(`[analyzeDocument] Fetching document content: ${docUrl}`);
    const response = await axios.get(docUrl, { responseType: 'text' });
    const dom = new JSDOM(response.data);
    const document = dom.window.document;
    const textContent = document.body.textContent || '';

    const relevantText = textContent
      .split('\n')
      .map(p => p.trim())
      .filter(p =>
        /ochrana|osobních|cookies|zásady|terms|privacy|gdpr|soukromí|uživatel|podmínky|zpracování/i.test(p)
      )
      .slice(0, 100)
      .join('\n\n');

    const SYSTEM_PROMPT = `
You are Grok 3 by xAI, an analytic assistant specialized in assessing documents like **Cookies Policy**, **Privacy Policy**, and **Terms of Use**. Your task is to provide a concise, critical analysis for laypeople, focusing on deficiencies, legal risks, or ambiguities in compliance with GDPR (EU Regulation 2016/679), Czech law (e.g. Civil Code No. 89/2012 Coll.; Consumer Protection Act No. 634/1992 Coll.), and the ePrivacy Directive (for cookies). Jurisdiction is Czech Republic.

**Instructions for your response:**
- Start with a score (0–100) reflecting document quality, legal compliance, and clarity.
- Provide only criticism, each including:
  - Brief description of the issue.
  - Direct citation (if relevant).
  - Why this is a problem (with reference to GDPR or Czech law).
  - A short suggestion to fix it.
- Finish with a summary of main issues and one key recommendation.

Use simple language understandable by laypeople.
Respond in Czech.
Maximum 500 words.
Do not request further info or questions.
`.trim();

    const USER_PROMPT = `
Please provide a concise analysis of the document type **[Cookies Policy / Privacy Policy / Terms of Use]** (determine type based on text). Document content:

${relevantText}
`.trim();

    const payload = {
      model: GROG_MODEL,
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: USER_PROMPT },
      ],
      temperature: 0.5,
      top_p: 0.8,
    };

    console.log(`[analyzeDocument] Sending request to Grok API for: ${docUrl}`);

    const grogResponse = await axios.post(GROG_API_URL, payload, {
      headers: {
        'Authorization': `Bearer ${GROG_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });

    const result = grogResponse.data;
    const output = result?.choices?.[0]?.message?.content || '[No response]';

    console.log(`--- Grok analysis output for (${docUrl}) ---`);
    console.log(output);
    console.log(`--- End of output ---\n`);

    return output;
  } catch (error: any) {
    console.error(`[analyzeDocument] Failed to analyze ${docUrl}:`, error.response?.data || error.message || error);
    throw new Error(`Failed to analyze document: ${docUrl}`);
  }
}
