/**
 * Retrieves a previously generated report from Supabase.
 */
import type { VercelRequest, VercelResponse } from '@vercel/node';
import { supabase } from '../utils/supabaseClient';
import type { AuditReport } from '../types/types';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const { id } = req.query as { id: string };
  // TODO: fetch from Supabase
  const report: AuditReport = {
    complianceScore: 0,
    missingDocuments: [],
    detectedTrackers: [],
  };
  res.json(report);
}
