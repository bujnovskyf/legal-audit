import 'package:flutter/foundation.dart';
import '../models/audit_result.dart';
import '../services/api_service.dart';

class AuditProvider extends ChangeNotifier {
  String? _auditId;
  AuditResult? _result;
  bool _loading = false;
  String? _error;

  AuditResult? get result => _result;
  String? get auditId => _auditId;
  bool get loading => _loading;
  String? get error => _error;

  Map<String, dynamic> get documentUrls => _result?.docUrls ?? {};

  Future<void> startAudit(String url) async {
    _setLoading(true);
    _setError(null);
    _result = null;
    _auditId = null;

    try {
      final initial = await ApiService.startAudit(url);
      _auditId = initial.auditId;

      await ApiService.scanAudit(_auditId!);

      _result = await ApiService.getAuditResult(_auditId!);
    } catch (e) {
      _setError(e.toString());
      _result = null;
      _auditId = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDocumentUrls(Map<String, dynamic> updatedUrls) async {
    if (_auditId == null) {
      _setError('Audit ID is null, cannot update document URLs.');
      return;
    }
    _setLoading(true);

    try {
      await ApiService.updateDocumentUrls(
        auditId: _auditId!,
        privacyUrl: updatedUrls['privacy_policy_url'],
        cookieUrl: updatedUrls['cookie_policy_url'],
        termsUrl: updatedUrls['terms_of_use_url'],
      );
      await ApiService.scanAudit(_auditId!);
      _result = await ApiService.getAuditResult(_auditId!);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> runAIAnalysis() async {
    if (_auditId == null) {
      _setError('Audit ID is null, cannot run AI analysis.');
      return;
    }
    _setLoading(true);
    _setError(null);

    try {
      await ApiService.runAIAnalysis(_auditId!);
      await Future.delayed(const Duration(seconds: 3));
      _result = await ApiService.getAuditResult(_auditId!);
    } catch (e) {
      // Special handling for HTTP 429
      if (e.toString().contains('429')) {
        _setError('AI analýza už byla provedena.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> refreshResult(String auditId) async {
    _setLoading(true);
    try {
      _result = await ApiService.getAuditResult(auditId);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
