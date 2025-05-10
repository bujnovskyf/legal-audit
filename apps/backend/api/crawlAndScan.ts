// Purpose: Crawl a given URL, scan for trackers and required legal documents,
//          compute a compliance report, save it to Supabase, and return the report.

import type { VercelRequest, VercelResponse } from '@vercel/node';
import { fetchHtml } from '../utils/fetchHtml';
import { detectTrackers } from '../utils/detectTrackers';
import { detectDocuments } from '../utils/detectDocuments';
import { supabase } from '../utils/supabaseClient';
import type { AuditReport } from '../types/types';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  try {
    const { url } = req.query as { url?: string };
    if (!url) {
      return res.status(400).json({ error: 'Missing `url` parameter' });
    }

    const html = await fetchHtml(url);

    const detectedTrackers = detectTrackers(html);

    const foundDocs = detectDocuments(html);

    const requiredDocs = ['Privacy Policy', 'Cookie Policy', 'Terms of Use'];
    const missingDocuments = requiredDocs.filter(doc => !foundDocs.includes(doc));

    let complianceScore = 100;
    complianceScore -= missingDocuments.length * 20; // -20% per missing doc
    complianceScore -= detectedTrackers.length * 5;  // -5% per tracker found
    complianceScore = Math.max(0, Math.min(100, complianceScore)); // clamp between 0–100

    const report: AuditReport = {
      complianceScore,
      missingDocuments,
      detectedTrackers,
    };

    const { error: dbError } = await supabase
      .from('audits')
      .insert([
        {
          url,
          compliance_score: complianceScore,
          missing_documents: missingDocuments,
          detected_trackers: detectedTrackers,
        },
      ]);

    if (dbError) {
      console.error('Supabase insert error:', dbError);
      // Continue to return report even if saving fails
    }

    // 7) Return the report as JSON
    return res.status(200).json(report);
  } catch (error: any) {
    console.error('crawlAndScan error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
}
