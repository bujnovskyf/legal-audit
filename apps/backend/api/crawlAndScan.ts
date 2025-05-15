import type { VercelRequest, VercelResponse } from '@vercel/node'
import { fetchHtml } from '../utils/fetchHtml'
import { detectTrackers } from '../utils/detectTrackers'
import { detectDocuments } from '../utils/detectDocuments'
import { supabase } from '../utils/supabaseClient'

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const origin = process.env.FRONTEND_URL ?? ''
  res.setHeader('Access-Control-Allow-Origin', origin)
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type')
  if (req.method === 'OPTIONS') return res.status(204).end()

  try {
    const { url } = req.query as { url?: string }
    if (!url) return res.status(400).json({ error: 'Missing `url` parameter' })

    const html = await fetchHtml(url)
    const detectedTrackers = await detectTrackers(html, url)
    const foundDocs = detectDocuments(html)
    const requiredDocs = ['Privacy Policy', 'Cookie Policy', 'Terms of Use']
    const missingDocuments = requiredDocs.filter(d => !foundDocs.includes(d))

    const { error } = await supabase
      .from('audits')
      .insert([{ url, missing_documents: missingDocuments, detected_trackers: detectedTrackers }])
    if (error) console.error('Supabase insert error:', error)

    return res.status(200).json({ missingDocuments, detectedTrackers })
  } catch (err: any) {
    console.error('crawlAndScan error:', err)
    return res.status(500).json({ error: 'Internal Server Error' })
  }
}
