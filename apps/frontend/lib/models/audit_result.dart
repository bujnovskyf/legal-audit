// Represents the result of a website audit.
class AuditResult {
  final double complianceScore;
  final List<String> missingDocuments;
  final List<String> detectedTrackers;

  AuditResult({
    required this.complianceScore,
    required this.missingDocuments,
    required this.detectedTrackers,
  });

  // Placeholder for parsing from JSON
  factory AuditResult.fromJson(Map<String, dynamic> json) {
    return AuditResult(
      complianceScore: 0.0,
      missingDocuments: [],
      detectedTrackers: [],
    );
  }
}
