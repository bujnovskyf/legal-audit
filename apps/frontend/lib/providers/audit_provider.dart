// Purpose: Manage audit state and trigger API calls.
import 'package:flutter/foundation.dart';
import '../models/audit_result.dart';
import '../services/api_service.dart';

class AuditProvider extends ChangeNotifier {
  AuditResult? _result;
  bool _loading = false;
  String? _error;

  AuditResult? get result => _result;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> runAudit(String url) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final r = await ApiService.runAudit(url);
      _result = r;
    } catch (e) {
      _error = e.toString();
      _result = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}