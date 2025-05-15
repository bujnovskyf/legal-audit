export interface TrackerInfo {
    name: string;
    consent?: string | boolean;
  }
  
  /** The shape of an audit result */
  export interface AuditReport {
    complianceScore: number;
    missingDocuments: string[];
    detectedTrackers: TrackerInfo[];
  }
  