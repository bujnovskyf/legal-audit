// Purpose: Interact with backend API endpoints (crawlAndScan, getReport).
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audit_result.dart';

class ApiService {
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static Future<AuditResult> runAudit(String url) async {
    final uri = Uri.parse('$_apiBase/crawlAndScan?url=$url');
    final response = await http.get(uri);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuditResult.fromJson(data);
  }

  static Future<AuditResult> getReport(String id) async {
    final uri = Uri.parse('$_apiBase/getReport?id=$id');
    final response = await http.get(uri);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AuditResult.fromJson(json);
  }
}