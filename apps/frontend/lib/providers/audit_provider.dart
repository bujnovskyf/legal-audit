import 'package:flutter/foundation.dart';
import '../models/audit_result.dart';
import '../services/api_service.dart';

class AuditProvider extends ChangeNotifier {
  String? _auditId;
  AuditResult? _result;
  bool _loading = false;
  String? _error;
  bool? _fromCache;
  String? _lastAuditedUrl; // <--- UX feature

  // --- Getters
  AuditResult? get result => _result;
  String? get auditId => _auditId;
  bool get loading => _loading;
  String? get error => _error;
  bool? get fromCache => _fromCache;
  String? get lastAuditedUrl => _lastAuditedUrl;

  Map<String, dynamic> get documentUrls => _result?.docUrls ?? {};
  String? get originalUrl => _result?.originalUrl;

  // --- Start audit, also set lastAuditedUrl
  Future<void> startAudit(String url, {bool force = false}) async {
    _setLoading(true);
    _setError(null);
    _result = null;
    _auditId = null;
    _fromCache = null;
    _lastAuditedUrl = url; // <- Save last audited URL

    try {
      final response = await ApiService.startAudit(url, force: force);
      _fromCache = response['fromCache'] ?? false;
      final auditId = response['auditId'];

      if (_fromCache == false && auditId != null) {
        await ApiService.scanAudit(auditId);
      }

      _result = await ApiService.getAuditResult(auditId ?? '');
      _auditId = auditId;
    } catch (e) {
      _fromCache = null;
      _setError(_humanizeError(e));
      _result = null;
      _auditId = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDocumentUrls(Map<String, dynamic> updatedUrls, {bool silent = false}) async {
    if (_auditId == null) {
      _setError('Audit ID is null, cannot update document URLs.');
      return;
    }
    if (!silent) _setLoading(true);

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
      notifyListeners(); // Překreslí jen, když se změní data
    } catch (e) {
      _setError(_humanizeError(e));
    } finally {
      if (!silent) _setLoading(false);
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
      if (e.toString().contains('429')) {
        _setError('AI analýza už byla provedena. (chyba 429)');
      } else {
        _setError(_humanizeError(e));
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
      _setError(_humanizeError(e));
    } finally {
      _setLoading(false);
    }
  }

  String _humanizeError(Object e) {
    final errorString = e.toString();
    if (errorString.contains('500')) {
      return 'Server nedokázal stránku zpracovat. Zkontrolujte, že zadáváte platnou a existující webovou adresu. (chyba 500)';
    }
    if (errorString.contains('404')) {
      return 'Stránka nebyla nalezena. (chyba 404)';
    }
    if (errorString.contains('429')) {
      return 'Příliš mnoho požadavků. Zkuste to prosím později. (chyba 429)';
    }
    if (errorString.contains('Failed host lookup') ||
        errorString.contains('SocketException')) {
      return 'Zadaná adresa není dostupná. Zkontrolujte připojení nebo platnost adresy. (detail: $errorString)';
    }
    return 'Nastala chyba při zpracování. ($errorString)';
  }

  // Helper for homepage: clean last audited url if needed
  void clearLastAuditedUrl() {
    _lastAuditedUrl = null;
    notifyListeners();
  }
}
