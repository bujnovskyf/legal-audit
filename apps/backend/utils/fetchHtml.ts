import axios, { AxiosError } from 'axios';

export async function fetchHtml(url: string): Promise<string> {
  const headers = {
    'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' +
      'AppleWebKit/537.36 (KHTML, like Gecko) ' +
      'Chrome/114.0.0.0 Safari/537.36',
    'Accept':
      'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'cs-CZ,cs;q=0.9,en;q=0.8',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
    'Referer': url,
  };

  try {
    const response = await axios.get<string>(url, {
      headers,
      timeout: 10_000,
      responseType: 'text',
      maxRedirects: 5,
      validateStatus: status => status >= 200 && status < 400,
    });
    return response.data;
  } catch (err) {
    if (axios.isAxiosError(err)) {
      const e = err as AxiosError;
      throw new Error(
        `fetchHtml(${url}) failed: ${e.response?.status} ${e.response?.statusText}`
      );
    }
    throw err;
  }
}