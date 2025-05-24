class AuditResult {
  final String? auditId;
  final String? originalUrl;
  final double complianceScore;
  final List<String> missingDocuments;
  final List<String> detectedTrackers;
  final Map<String, dynamic>? docUrls;
  final Map<String, dynamic>? grokOutputs;

  AuditResult({
    this.auditId,
    this.originalUrl,
    required this.complianceScore,
    required this.missingDocuments,
    required this.detectedTrackers,
    this.docUrls,
    this.grokOutputs,
  });

  factory AuditResult.fromJson(Map<String, dynamic> json) {
    final audit = json['audit'] ?? {};
    final url = audit['url'] ?? json['url'];
    return AuditResult(
      auditId: audit['id'] as String? ?? json['auditId'] as String?,
      originalUrl: url as String?,
      complianceScore: (audit['compliance_score'] as num?)?.toDouble() ?? 0.0,
      missingDocuments: List<String>.from(audit['missing_documents'] ?? []),
      detectedTrackers: List<String>.from(audit['detected_trackers'] ?? []),
      docUrls: json['docUrls'] != null ? Map<String, dynamic>.from(json['docUrls']) : null,
      grokOutputs: json['grok'] != null ? Map<String, dynamic>.from(json['grok']) : null,
    );
  }

  AuditResult copyWith({
    String? auditId,
    String? originalUrl,
    double? complianceScore,
    List<String>? missingDocuments,
    List<String>? detectedTrackers,
    Map<String, dynamic>? docUrls,
    Map<String, dynamic>? grokOutputs,
  }) {
    return AuditResult(
      auditId: auditId ?? this.auditId,
      originalUrl: originalUrl ?? this.originalUrl,
      complianceScore: complianceScore ?? this.complianceScore,
      missingDocuments: missingDocuments ?? this.missingDocuments,
      detectedTrackers: detectedTrackers ?? this.detectedTrackers,
      docUrls: docUrls ?? this.docUrls,
      grokOutputs: grokOutputs ?? this.grokOutputs,
    );
  }
}