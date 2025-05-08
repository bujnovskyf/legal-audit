/**
 * Crawl a website and scan for cookie banners, trackers,
 * and required legal documents.
 */
import type { VercelRequest, VercelResponse } from '@vercel/node';
import { fetchHtml } from '../utils/fetchHtml';
import { detectTrackers } from '../utils/detectTrackers';
import type { AuditReport } from '../types/types';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const { url } = req.query as { url: string };
  // TODO: implement crawl & scan
  const report: AuditReport = {
    complianceScore: 0,
    missingDocuments: [],
    detectedTrackers: [],
  };
  res.json(report);
}
