import type { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../../utils/supabaseClient';
import { withCors } from '../../../utils/cors';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.status(405).end();
    return;
  }

  const { auditId, privacy_policy_url, cookie_policy_url, terms_of_use_url } = req.body;
  if (!auditId) {
    res.status(400).json({ error: 'Missing auditId' });
    return;
  }

  try {
    const { error } = await supabase
      .from('audit_document_urls')
      .update({
        privacy_policy_url: privacy_policy_url || null,
        cookie_policy_url: cookie_policy_url || null,
        terms_of_use_url: terms_of_use_url || null,
      })
      .eq('audit_id', auditId);

    if (error) {
      res.status(500).json({ error: error.message || 'Failed to update document URLs' });
      return;
    }

    res.status(200).json({ message: 'Document URLs updated' });
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
}

export default withCors(handler);
