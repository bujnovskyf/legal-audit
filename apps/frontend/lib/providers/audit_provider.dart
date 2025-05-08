// State management for audit process.
import 'package:flutter/foundation.dart';
import '../models/audit_result.dart';
import '../services/api_service.dart';

class AuditProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuditResult? _result;
  bool _loading = false;

  AuditResult? get result => _result;
  bool get loading => _loading;

  Future<void> runAudit(String url) async {
    _loading = true;
    notifyListeners();

    // TODO: call API
    _result = await _apiService.runAudit(url);

    _loading = false;
    notifyListeners();
  }
}
