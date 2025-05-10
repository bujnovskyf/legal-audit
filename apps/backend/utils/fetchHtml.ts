// Purpose: Download the HTML content of a target website as a string.

import axios from 'axios';

/**
 * Fetches the raw HTML from the given URL.
 * @param url The web address to download.
 * @returns A promise that resolves with the full HTML content.
 */
export async function fetchHtml(url: string): Promise<string> {
  // TODO: add URL validation, timeout settings, or retry logic as needed
  const response = await axios.get<string>(url, {
    headers: { 'User-Agent': 'LegalAuditBot/1.0' },
  });
  return response.data;
}
