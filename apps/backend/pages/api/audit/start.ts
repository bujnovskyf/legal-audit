import type { NextApiRequest, NextApiResponse } from 'next';
import { detectDocuments } from '../../../utils/detectDocuments';
import { supabase } from '../../../utils/supabaseClient';
import { withCors } from '../../../utils/cors';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.status(405).end();
    return;
  }

  const { url, force } = req.body;
  if (!url) {
    res.status(400).json({ error: 'Missing URL' });
    return;
  }

  try {
    if (!force) {
      const { data: recentAudits, error: searchError } = await supabase
        .from('audits')
        .select('id, created_at')
        .eq('url', url)
        .order('created_at', { ascending: false })
        .limit(1);

      if (searchError) throw new Error(searchError.message);

      if (
        recentAudits &&
        recentAudits.length > 0 &&
        Date.now() - new Date(recentAudits[0].created_at).getTime() < 60 * 60 * 1000
      ) {
        const auditId = recentAudits[0].id;

        const { data: auditRow, error: auditErr } = await supabase
          .from('audits')
          .select('*')
          .eq('id', auditId)
          .single();

        const { data: docUrls } = await supabase
          .from('audit_document_urls')
          .select('*')
          .eq('audit_id', auditId)
          .single();

        const { data: grokOutput } = await supabase
          .from('audit_grok_outputs')
          .select('*')
          .eq('audit_id', auditId)
          .single();

        res.status(200).json({
          auditId,
          url, 
          docUrls,
          fromCache: true,
          audit: auditRow,
          grok: grokOutput || {},
        });
        return;
      }
    }

    const { data: audit, error: auditError } = await supabase
      .from('audits')
      .insert([{ url }])
      .select('id')
      .single();

    if (auditError || !audit?.id) {
      res.status(500).json({ error: auditError?.message || 'Audit insert failed' });
      return;
    }

    const docs = await detectDocuments(url, { analyze: false });

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

    res.status(200).json({
      auditId: audit.id,
      url,
      docUrls,
      fromCache: false,
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
}

export default withCors(handler);
