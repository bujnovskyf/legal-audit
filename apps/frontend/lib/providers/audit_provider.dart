import 'package:flutter/foundation.dart';
import '../models/audit_result.dart';
import '../services/api_service.dart';

class AuditProvider extends ChangeNotifier {
  String? _auditId;
  AuditResult? _result;
  bool _loading = false;
  String? _errorKey;
  bool? _fromCache;
  String? _lastAuditedUrl;
  String _aiLanguage = 'cs';

  AuditResult? get result => _result;
  String? get auditId => _auditId;
  bool get loading => _loading;
  String? get errorKey => _errorKey;
  bool? get fromCache => _fromCache;
  String? get lastAuditedUrl => _lastAuditedUrl;
  String get aiLanguage => _aiLanguage;

  Map<String, dynamic> get documentUrls => _result?.docUrls ?? {};
  String? get originalUrl => _result?.originalUrl;

  void setAiLanguage(String langCode) {
    if (_aiLanguage != langCode) {
      _aiLanguage = langCode;
      notifyListeners();
    }
  }

  Future<void> startAudit(String url, {bool force = false}) async {
    _setLoading(true);
    _setErrorKey(null);

    final prevAuditId = _auditId;
    _lastAuditedUrl = url; // uložíme URL pro případ opakování auditu

    try {
      final response = await ApiService.startAudit(url, force: force);

      _fromCache = response['fromCache'] ?? false;
      final auditId = response['auditId'];

      if (_fromCache == false && auditId != null) {
        await ApiService.scanAudit(auditId);
      }

      _result = await ApiService.getAuditResult(auditId ?? '');
      _auditId = auditId;

      // Pokud je nový auditId odlišný od předchozího, vyčistíme AI výstupy
      if (auditId != prevAuditId) {
        _result = _result?.copyWith(grokOutputs: null);
      }

      notifyListeners();
    } catch (e) {
      _fromCache = null;
      _setErrorKey(_errorKeyFromException(e));
      _result = null;
      _auditId = null;
      _lastAuditedUrl = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDocumentUrls(Map<String, dynamic> updatedUrls, {bool silent = false}) async {
    if (_auditId == null) {
      _setErrorKey('error.auditIdNull');
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
      _setErrorKey(null);
      notifyListeners();
    } catch (e) {
      _setErrorKey(_errorKeyFromException(e));
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  Future<void> runAIAnalysis({required String language}) async {
    if (_auditId == null) {
      _setErrorKey('error.auditIdNull');
      return;
    }
    _setLoading(true);
    _setErrorKey(null);

    try {
      await ApiService.runAIAnalysis(_auditId!, language: language);
      // Čekáme, než backend dokončí AI analýzu
      await Future.delayed(const Duration(seconds: 3));
      _result = await ApiService.getAuditResult(_auditId!);
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('429')) {
        _setErrorKey('error.aiAlreadyRun');
      } else {
        _setErrorKey(_errorKeyFromException(e));
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshResult(String auditId) async {
    _setLoading(true);
    try {
      _result = await ApiService.getAuditResult(auditId);
      _setErrorKey(null);
    } catch (e) {
      _setErrorKey(_errorKeyFromException(e));
    } finally {
      _setLoading(false);
    }
  }

  void clearLastAuditedUrl() {
    _lastAuditedUrl = null;
    notifyListeners();
  }

  void clearAiOutput() {
    if (_result != null) {
      _result = AuditResult(
        auditId: _result!.auditId,
        docUrls: _result!.docUrls,
        grokOutputs: {}, // vyčistíme AI výstupy
        complianceScore: _result!.complianceScore,
        missingDocuments: _result!.missingDocuments,
        detectedTrackers: _result!.detectedTrackers,
        originalUrl: _result!.originalUrl,
      );
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setErrorKey(String? value) {
    _errorKey = value;
    notifyListeners();
  }

  String _errorKeyFromException(Object e) {
    final errorString = e.toString();
    if (errorString.contains('500')) return 'error.500';
    if (errorString.contains('404')) return 'error.404';
    if (errorString.contains('429')) return 'error.429';
    if (errorString.contains('Failed host lookup') || errorString.contains('SocketException')) return 'error.network';
    return 'error.generic';
  }
}
