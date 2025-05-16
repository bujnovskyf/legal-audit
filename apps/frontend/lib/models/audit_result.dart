class AuditResult {
  final String? auditId;
  final String? url;
  final double complianceScore;
  final List<String> missingDocuments;
  final List<String> detectedTrackers;
  final Map<String, dynamic>? docUrls;
  final Map<String, dynamic>? grokOutputs;

  AuditResult({
    this.auditId,
    this.url,
    required this.complianceScore,
    required this.missingDocuments,
    required this.detectedTrackers,
    this.docUrls,
    this.grokOutputs,
  });

  factory AuditResult.fromJson(Map<String, dynamic> json) {
    final audit = json['audit'] ?? {};
    return AuditResult(
      auditId: audit['id'] as String?,
      url: audit['url'] as String?,
      complianceScore: (audit['compliance_score'] as num?)?.toDouble() ?? 0.0,
      missingDocuments: List<String>.from(audit['missing_documents'] ?? []),
      detectedTrackers: List<String>.from(audit['detected_trackers'] ?? []),
      docUrls: json['docUrls'] != null ? Map<String, dynamic>.from(json['docUrls']) : null,
      grokOutputs: json['grok'] != null ? Map<String, dynamic>.from(json['grok']) : null,
    );
  }
}
