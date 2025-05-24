import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'audit_provider.dart';
import '../pages/result_page.dart';

class ResultPageController extends ChangeNotifier {
  String auditId;
  final BuildContext context;
  final void Function(Locale) onLocaleChange;

  bool isLoading = false;
  bool aiLoading = false;
  bool aiResultsVisible = false;
  String? aiError;
  bool submittingAgain = false;
  bool auditFromCache = false;

  final Map<String, TextEditingController> controllers = {
    'privacy_policy_url': TextEditingController(),
    'cookie_policy_url': TextEditingController(),
    'terms_of_use_url': TextEditingController(),
  };

  bool _disposed = false;

  ResultPageController({
    required this.context,
    required this.auditId,
    required this.onLocaleChange,
  }) {
    Future.microtask(_init);
  }

  AuditProvider get _provider => context.read<AuditProvider>();

  Future<void> _init() async {
    isLoading = true;
    _safeNotifyListeners();
    await loadResult();
    if (_disposed) return;
    isLoading = false;
    _safeNotifyListeners();
  }

  Future<bool> loadResult() async {
    await _provider.refreshResult(auditId);

    if (_disposed) return false;

    auditFromCache = _provider.fromCache == true;
    final urls = _provider.result?.docUrls ?? {};
    controllers.forEach((key, ctrl) {
      ctrl.text = (urls[key] ?? '').toString();
    });
    final grok = _provider.result?.grokOutputs;

    aiResultsVisible = grok != null && grok.isNotEmpty;

    _safeNotifyListeners();
    return aiResultsVisible;
  }

  Future<void> updateUrlField(String key) async {
    final l10n = AppLocalizations.of(context)!;
    final newUrls = controllers.map((k, ctrl) => MapEntry(k, ctrl.text.trim()));
    try {
      await _provider.updateDocumentUrls(newUrls, silent: true);
    } catch (e, s) {
      debugPrint('Update URL field error: $e\n$s');
      if (_disposed) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorUpdateUrl)),
      );
    }
    _safeNotifyListeners();
  }

  Future<void> runAnalysis() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    aiLoading = true;
    aiError = null;
    aiResultsVisible = false;
    _safeNotifyListeners();

    try {
      await _provider.runAIAnalysis(language: locale.languageCode);
      final hasAiOutputs = await loadResult();
      if (_disposed) return;

      aiLoading = false;
      aiResultsVisible = hasAiOutputs;
      if (_provider.errorKey == 'error.aiAlreadyRun') {
        aiError = l10n.errorAiAlreadyRun;
      }
    } catch (e) {
      if (_disposed) return;
      aiLoading = false;
      aiError = e.toString();
      aiResultsVisible = false;
    }
    _safeNotifyListeners();
  }

  Future<void> runAgain() async {
    final l10n = AppLocalizations.of(context)!;

    submittingAgain = true;
    aiResultsVisible = false;
    aiError = null;
    auditFromCache = false;
    _safeNotifyListeners();

    final url = _provider.result?.originalUrl ?? _provider.lastAuditedUrl ?? '';
    if (url.isEmpty) {
      if (_disposed) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorNoUrl)),
      );
      submittingAgain = false;
      _safeNotifyListeners();
      return;
    }

    await _provider.startAudit(url, force: true);
    final newAuditId = _provider.result?.auditId;
    if (_disposed) return;

    submittingAgain = false;

    if (newAuditId != null && newAuditId != auditId) {
      if (_disposed) return;
      // Naviguj na nový result page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            auditId: newAuditId,
            onLocaleChange: onLocaleChange,
          ),
        ),
      );
      return;
    }
    await loadResult();
    _safeNotifyListeners();
  }

  String mapErrorKeyToMessage(AppLocalizations l10n, String? errorKey) {
    switch (errorKey) {
      case 'error.500':
        return l10n.error500;
      case 'error.404':
        return l10n.error404;
      case 'error.429':
        return l10n.error429;
      case 'error.aiAlreadyRun':
        return l10n.errorAiAlreadyRun;
      case 'error.network':
        return l10n.errorNetwork('');
      default:
        return l10n.errorGeneric(errorKey ?? '');
    }
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
