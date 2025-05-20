import type { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../../utils/supabaseClient';
import { withCors } from '../../../utils/cors';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    res.status(405).end();
    return;
  }

  const { auditId } = req.query;
  if (!auditId || typeof auditId !== 'string') {
    res.status(400).json({ error: 'Missing auditId' });
    return;
  }

  try {
    // Audit detail
    const { data: audit, error: auditError } = await supabase
      .from('audits')
      .select('id, url, compliance_score, missing_documents, detected_trackers, created_at')
      .eq('id', auditId)
      .single();
    if (auditError || !audit) {
      res.status(404).json({ error: auditError?.message || 'Audit not found' });
      return;
    }

    // Grok outputs (map keys for frontend)
    let grok = null;
    try {
      const grokRes = await supabase
        .from('audit_grok_outputs')
        .select('*')
        .eq('audit_id', auditId)
        .single();
      if (grokRes.data) {
        grok = {
          privacy_policy_url: grokRes.data.privacy_policy_output,
          cookie_policy_url: grokRes.data.cookie_policy_output,
          terms_of_use_url: grokRes.data.terms_of_use_output,
        };
      } else {
        grok = null;
      }
    } catch (grokError) {
      grok = null;
    }

    // Doc URLs
    const { data: docUrls, error: docUrlsError } = await supabase
      .from('audit_document_urls')
      .select('*')
      .eq('audit_id', auditId)
      .single();
    if (docUrlsError || !docUrls) {
      res.status(404).json({ error: docUrlsError?.message || 'Document URLs not found' });
      return;
    }

    res.status(200).json({ audit, grok, docUrls });
  } catch (err: any) {
    console.error('API /audit/result error:', err);
    res.status(500).json({ error: err?.message || 'Internal server error' });
  }
}

export default withCors(handler);
