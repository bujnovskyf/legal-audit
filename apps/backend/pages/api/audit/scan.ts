import type { NextApiRequest, NextApiResponse } from 'next';
import { fetchHtml } from '../../../utils/fetchHtml';
import { detectTrackers } from '../../../utils/detectTrackers';
import { detectDocuments } from '../../../utils/detectDocuments';
import { supabase } from '../../../utils/supabaseClient';
import { withCors } from '../../../utils/cors';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.status(405).end();
    return;
  }

  const { auditId } = req.body;
  if (!auditId) {
    res.status(400).json({ error: 'Missing auditId' });
    return;
  }

  try {
    // Získáme URL auditu
    const { data: audit, error } = await supabase
      .from('audits')
      .select('url')
      .eq('id', auditId)
      .single();

    if (error || !audit?.url) {
      res.status(404).json({ error: error?.message || 'Audit not found' });
      return;
    }

    const html = await fetchHtml(audit.url);
    const detectedTrackers = await detectTrackers(html, audit.url);
    // Pokud funkce detectDocuments bere druhý parametr options:
    const foundDocs = await detectDocuments(audit.url, { analyze: false });

    const requiredDocs = ['Privacy Policy', 'Cookie Policy', 'Terms of Use'];
    const foundDocTypes = foundDocs.map((doc: any) => doc.type);
    const missingDocuments = requiredDocs.filter(doc => !foundDocTypes.includes(doc));

    let complianceScore = 100;
    complianceScore -= missingDocuments.length * 20;
    complianceScore -= (detectedTrackers.length || 0) * 5;
    complianceScore = Math.max(0, Math.min(100, complianceScore));

    await supabase
      .from('audits')
      .update({
        compliance_score: complianceScore,
        missing_documents: missingDocuments,
        detected_trackers: detectedTrackers,
      })
      .eq('id', auditId);

    res.status(200).json({
      complianceScore,
      missingDocuments,
      detectedTrackers,
      foundDocs,
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
}

export default withCors(handler);
