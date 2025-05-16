// Purpose: Crawl a given URL, scan for trackers and required legal documents,
//          compute a compliance report, save it to Supabase, and return the report.

import type { VercelRequest, VercelResponse } from '@vercel/node';
import { fetchHtml } from '../utils/fetchHtml';
import { detectTrackers } from '../utils/detectTrackers';
import { detectDocuments } from '../utils/detectDocuments';
import { supabase } from '../utils/supabaseClient';
import type { AuditReport } from '../types/types';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const allowedOrigin = process.env.FRONTEND_URL || '';
  res.setHeader('Access-Control-Allow-Origin', allowedOrigin);
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  try {
    const { url } = req.query as { url?: string };
    if (!url) {
      return res.status(400).json({ error: 'Missing `url` parameter' });
    }

    const html = await fetchHtml(url);
    const detectedTrackers = detectTrackers(html);
    const foundDocs = await detectDocuments(url);

    const requiredDocs = ['Privacy Policy', 'Cookie Policy', 'Terms of Use'];
    const foundDocTypes = foundDocs.map(doc => doc.type);
    const missingDocuments = requiredDocs.filter(doc => !foundDocTypes.includes(doc));

    let complianceScore = 100;
    complianceScore -= missingDocuments.length * 20;
    complianceScore -= detectedTrackers.length * 5;
    complianceScore = Math.max(0, Math.min(100, complianceScore));

    const { error: dbError } = await supabase
      .from('audits')
      .insert([
        {
          url,
          compliance_score: complianceScore,
          missing_documents: missingDocuments,
          detected_trackers: detectedTrackers,
          grok_output: JSON.stringify(foundDocs),
        },
      ]);

    if (dbError) {
      console.error('Supabase insert error:', dbError);
    }

    return res.status(200).json({
      complianceScore,
      missingDocuments,
      detectedTrackers,
      documentSummaries: foundDocs,
    });
  } catch (error: any) {
    console.error('crawlAndScan error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
}
