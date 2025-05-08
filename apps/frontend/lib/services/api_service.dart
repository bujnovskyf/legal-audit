// Handles HTTP calls to the backend API.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audit_result.dart';

class ApiService {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const apiBase = String.fromEnvironment('API_BASE_URL');

  ApiService();

  Future<AuditResult> runAudit(String url) async {
    // TODO: implement call to /api/crawlAndScan
    final response = await http.get(Uri.parse('$apiBase/crawlAndScan?url=$url'));
    final json = jsonDecode(response.body);
    return AuditResult.fromJson(json);
  }
}
