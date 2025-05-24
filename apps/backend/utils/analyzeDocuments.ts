import axios from 'axios';
import { JSDOM } from 'jsdom';

const GROK_API_KEY = process.env.GROK_API_KEY;
const GROK_API_URL = 'https://api.x.ai/v1/chat/completions';
const GROK_MODEL = 'grok-3-mini-latest';

if (!GROK_API_KEY) {
  throw new Error('GROK_API_KEY is missing in the environment.');
}

export async function analyzeDocument(docUrl: string, lang: string = 'cs'): Promise<string> {
  try {
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

    let outputLang = 'Czech';
    if (lang.toLowerCase().startsWith('en')) outputLang = 'English';

    const JURISDICTION = outputLang === 'Czech'
      ? `- **Jurisdiction:** Always analyze in accordance with the GDPR (Regulation (EU) 2016/679), Czech law (e.g., Act No. 89/2012 Coll., Civil Code; Act No. 634/1992 Coll., on Consumer Protection), and the ePrivacy Directive (for cookies). The applicable jurisdiction is always the Czech Republic.`
      : `- **Jurisdiction:** Always analyze in accordance with the GDPR (Regulation (EU) 2016/679) and the ePrivacy Directive (for cookies). Refer only to EU law.`;

    const SYSTEM_PROMPT = `
You are Grok 3, created by xAI. You are an analytical assistant specializing in evaluating documents such as Cookies Policies, Privacy Policies, or Terms of Use.

Your task is to provide a concise, critical analysis aimed at the general public, focusing only on deficiencies, legal risks, or ambiguities, in accordance with the applicable legislation.

${JURISDICTION}

**Instructions for the response:**
- Start with a percentage score (0–100) reflecting the quality of the document and its legal compliance.
- Only list criticisms; each issue must include:
  - A brief description of the problem.
  - A direct quote (if relevant).
  - Why it is a problem (with reference to the relevant legislation).
  - A short suggestion for improvement.
- End with a brief summary of the main issues and a single key recommendation.

**Focus:** Identify legal inconsistencies, unclear language, or missing information. Do not mention positive aspects.
**Brevity:** Keep the response under 500 words, unless otherwise specified.
**Legal context:** Refer to the appropriate articles of GDPR or ePrivacy Directive${outputLang === 'Czech' ? ' (and Czech law if applicable)' : ''}.
**Output:** Write in ${outputLang}, in a formal yet simple tone.

The document is always provided. Analyze only the given text. Never ask for additional questions or information. Do **not** include the total word count or any statement about the number of words. Consider the current date (${new Date().toLocaleDateString("en-GB")}) and any new legal regulations.
    `.trim();

    const USER_PROMPT = `
Conduct a brief analysis of the provided document of type [Cookies Policy / Privacy Policy / Terms of Use] (determine based on content). 

Document content:
${relevantText}
    `.trim();

    const payload = {
      model: GROK_MODEL,
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: USER_PROMPT },
      ],
      temperature: 0.4,
      top_p: 0.8,
      max_tokens: 4500,
      reasoning: {
        effort: "low",
        max_tokens: 300,
        exclude: false,
      },
    };

    const grokResponse = await axios.post(GROK_API_URL, payload, {
      headers: {
        'Authorization': `Bearer ${GROK_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });

    const result = grokResponse.data;
    const output = result?.choices?.[0]?.message?.content || '[No response]';

    return output;
  } catch (error: any) {
    throw new Error(`Failed to analyze document: ${docUrl}`);
  }
}