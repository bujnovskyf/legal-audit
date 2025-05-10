// Purpose: Retrieve a previously saved audit report by its ID from Supabase.

import type { VercelRequest, VercelResponse } from '@vercel/node';
import { supabase } from '../utils/supabaseClient';
import type { AuditReport } from '../types/types';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  try {
    const { id } = req.query as { id?: string };
    if (!id) {
      return res.status(400).json({ error: 'Missing `id` parameter' });
    }

    const { data, error } = await supabase
      .from('audits')
      .select('url, compliance_score, missing_documents, detected_trackers, created_at')
      .eq('id', id)
      .single();

    if (error) {
      console.error('getReport supabase error:', error);
      return res.status(500).json({ error: 'Database query failed' });
    }
    if (!data) {
      return res.status(404).json({ error: 'Report not found' });
    }

    const report: AuditReport = {
      complianceScore: data.compliance_score,
      missingDocuments: data.missing_documents,
      detectedTrackers: data.detected_trackers,
    };

    return res.status(200).json({ id, url: data.url, createdAt: data.created_at, ...report });
  } catch (err: any) {
    console.error('getReport handler error:', err);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
}
