export interface TrackerInfo {
    name: string;
    consent?: string | boolean;
  }
  
  export interface AuditReport {
    complianceScore: number;
    missingDocuments: string[];
    detectedTrackers: TrackerInfo[];
  }
  