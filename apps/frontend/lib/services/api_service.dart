import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audit_result.dart';

class ApiService {
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/audit',
  );

  static Future<AuditResult> startAudit(String url) async {
    final uri = Uri.parse('$_apiBase/start');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to start audit: ${response.statusCode}');
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AuditResult(
        auditId: data['auditId'] as String?,
        docUrls: (data['docUrls'] as Map?)?.cast<String, dynamic>(),
        grokOutputs: null,
        complianceScore: 0.0,
        missingDocuments: const [],
        detectedTrackers: const [],
      );
    } catch (e) {
      throw Exception('Invalid response format: $e');
    }
  }

  static Future<AuditResult> getAuditResult(String auditId) async {
    final uri = Uri.parse('$_apiBase/result?auditId=$auditId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to get audit result: ${response.statusCode}');
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final audit = data['audit'] as Map<String, dynamic>? ?? {};
      final docUrls = data['docUrls'] as Map<String, dynamic>? ?? {};
      final grok = data['grok'] as Map<String, dynamic>? ?? {};

      return AuditResult(
        auditId: audit['id'] ?? auditId,
        docUrls: docUrls,
        grokOutputs: grok,
        complianceScore: (audit['compliance_score'] as num?)?.toDouble() ?? 0.0,
        missingDocuments: (audit['missing_documents'] as List?)?.map((e) => e.toString()).toList() ?? [],
        detectedTrackers: (audit['detected_trackers'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
    } catch (e) {
      throw Exception('Invalid response format: $e');
    }
  }

  static Future<void> updateDocumentUrls({
    required String auditId,
    String? privacyUrl,
    String? cookieUrl,
    String? termsUrl,
  }) async {
    final uri = Uri.parse('$_apiBase/updateDocs');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'auditId': auditId,
        'privacy_policy_url': privacyUrl,
        'cookie_policy_url': cookieUrl,
        'terms_of_use_url': termsUrl,
      }),
    );

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to update document URLs');
      } catch (_) {
        throw Exception('Failed to update document URLs');
      }
    }
  }

  static Future<void> scanAudit(String auditId) async {
    final uri = Uri.parse('$_apiBase/scan');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'auditId': auditId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to scan audit: ${response.statusCode}');
    }
  }

  static Future<void> runAIAnalysis(String auditId) async {
    final uri = Uri.parse('$_apiBase/runAnalysis');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'auditId': auditId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to run AI analysis: ${response.statusCode}');
    }
  }
}
