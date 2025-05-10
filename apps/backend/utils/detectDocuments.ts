// Purpose: Scan HTML for links or keywords of required legal documents.

interface DocPattern { name: string; regex: RegExp }

const DOC_PATTERNS: DocPattern[] = [
  { name: 'Privacy Policy', regex: /href=.*privacy[-_ ]?policy/i },
  { name: 'Cookie Policy',  regex: /href=.*cookie[-_ ]?policy/i },
  { name: 'Terms of Use',    regex: /href=.*terms?[-_ ]?of?[-_ ]?use/i },
];

export function detectDocuments(html: string): string[] {
  const found = new Set<string>();
  for (const { name, regex } of DOC_PATTERNS) {
    if (regex.test(html)) {
      found.add(name);
    }
  }
  return Array.from(found);
}
