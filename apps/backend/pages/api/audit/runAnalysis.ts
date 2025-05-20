// api/audit/runAnalysis.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../../utils/supabaseClient';
import { analyzeDocument } from '../../../utils/analyzeDocuments';
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
    // 1) Zkontroluj, jestli už nějaká AI analýza pro ten auditId existuje
    const { data: existing, error: existingError } = await supabase
      .from('audit_grok_outputs')
      .select('*')
      .eq('audit_id', auditId)
      .single();

    // Pokud existuje a aspoň jeden výstup není null/'' (tedy už bylo analyzováno)
    if (
      existing &&
      (
        (existing.privacy_policy_output && existing.privacy_policy_output.trim() !== '') ||
        (existing.cookie_policy_output && existing.cookie_policy_output.trim() !== '') ||
        (existing.terms_of_use_output && existing.terms_of_use_output.trim() !== '')
      )
    ) {
      res.status(429).json({ error: 'AI analýza už byla provedena.' });
      return;
    }

    // 2) Získáme URL dokumentů
    const { data: docUrls, error } = await supabase
      .from('audit_document_urls')
      .select('*')
      .eq('audit_id', auditId)
      .single();
    if (error || !docUrls) {
      res.status(404).json({ error: 'Document URLs not found' });
      return;
    }

    // Pokud dokument chybí, vůbec neposílej request na Groka
    let privacyOutput: string | null = null;
    let cookieOutput: string | null = null;
    let termsOutput: string | null = null;

    if (docUrls.privacy_policy_url) {
      privacyOutput = await analyzeDocument(docUrls.privacy_policy_url);
    }
    if (docUrls.cookie_policy_url) {
      cookieOutput = await analyzeDocument(docUrls.cookie_policy_url);
    }
    if (docUrls.terms_of_use_url) {
      termsOutput = await analyzeDocument(docUrls.terms_of_use_url);
    }

    await supabase
      .from('audit_grok_outputs')
      .upsert([
        {
          audit_id: auditId,
          privacy_policy_output: privacyOutput,
          cookie_policy_output: cookieOutput,
          terms_of_use_output: termsOutput,
        },
      ], { onConflict: 'audit_id' });

    // Pro návratovou hodnotu:
    const results = {
      privacy_policy_url: privacyOutput,
      cookie_policy_url: cookieOutput,
      terms_of_use_url: termsOutput,
    };

    res.status(200).json({ results });
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
}

// Exportuj přes withCors (kvůli CORS preflight)
export default withCors(handler);
