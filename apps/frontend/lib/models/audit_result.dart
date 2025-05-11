// Purpose: Model representing audit results returned from backend.
class AuditResult {
  final double complianceScore;
  final List<String> missingDocuments;
  final List<String> detectedTrackers;

  AuditResult({
    required this.complianceScore,
    required this.missingDocuments,
    required this.detectedTrackers,
  });

  factory AuditResult.fromJson(Map<String, dynamic> json) {
    return AuditResult(
      complianceScore: (json['complianceScore'] as num).toDouble(),
      missingDocuments: List<String>.from(json['missingDocuments'] as List),
      detectedTrackers: List<String>.from(json['detectedTrackers'] as List),
    );
  }
}