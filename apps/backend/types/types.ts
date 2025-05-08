// Shared TypeScript types for API and utils.

export interface AuditReport {
    complianceScore: number;
    missingDocuments: string[];
    detectedTrackers: string[];
  }
  
  export interface CrawlResult {
    html: string;
  }
  