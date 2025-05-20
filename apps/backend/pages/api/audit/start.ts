import type { NextApiRequest, NextApiResponse } from 'next';
import { detectDocuments } from '../../../utils/detectDocuments';
import { supabase } from '../../../utils/supabaseClient';
import { withCors } from '../../../utils/cors';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.status(405).end();
    return;
  }

  const { url } = req.body;
  if (!url) {
    res.status(400).json({ error: 'Missing URL' });
    return;
  }

  try {
    // Vytvoření audit záznamu
    const { data: audit, error: auditError } = await supabase
      .from('audits')
      .insert([{ url }])
      .select('id')
      .single();

    if (auditError || !audit?.id) {
      res.status(500).json({ error: auditError?.message || 'Audit insert failed' });
      return;
    }

    // Detekce dokumentů (bez analýzy, jen URL)
    const docs = await detectDocuments(url, { analyze: false }); // uprav detectDocuments pokud je potřeba

    const docUrls: any = {
      audit_id: audit.id,
      privacy_policy_url: null,
      cookie_policy_url: null,
      terms_of_use_url: null,
    };
    docs.forEach((doc: any) => {
      if (doc.type === 'Privacy Policy') docUrls.privacy_policy_url = doc.url;
      if (doc.type === 'Cookie Policy') docUrls.cookie_policy_url = doc.url;
      if (doc.type === 'Terms of Use') docUrls.terms_of_use_url = doc.url;
    });

    await supabase.from('audit_document_urls').insert([docUrls]);

    res.status(200).json({ auditId: audit.id, docUrls });
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
}

export default withCors(handler);
