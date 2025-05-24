import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'audit_provider.dart';
import '../pages/result_page.dart'; // importuj správnou cestu!

class ResultPageController extends ChangeNotifier {
  String auditId;
  final BuildContext context;
  final void Function(Locale) onLocaleChange;

  // UI State
  bool isLoading = false;
  bool aiLoading = false;
  bool aiResultsVisible = false;
  String? aiError;
  bool submittingAgain = false;
  bool auditFromCache = false;

  // Controllers
  final Map<String, TextEditingController> controllers = {
    'privacy_policy_url': TextEditingController(),
    'cookie_policy_url': TextEditingController(),
    'terms_of_use_url': TextEditingController(),
  };

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
    notifyListeners();
    await loadResult();
    isLoading = false;
    notifyListeners();
  }

  Future<bool> loadResult() async {
    await _provider.refreshResult(auditId);

    auditFromCache = _provider.fromCache == true;
    final urls = _provider.result?.docUrls ?? {};
    controllers.forEach((key, ctrl) {
      ctrl.text = (urls[key] ?? '').toString();
    });
    final grok = _provider.result?.grokOutputs;

    aiResultsVisible = grok != null && grok.isNotEmpty;

    notifyListeners();
    return aiResultsVisible;
  }

  Future<void> updateUrlField(String key) async {
    final newUrls = controllers.map((k, ctrl) => MapEntry(k, ctrl.text.trim()));
    try {
      await _provider.updateDocumentUrls(newUrls, silent: true);
    } catch (e, s) {
      debugPrint('Update URL field error: $e\n$s');
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorUpdateUrl)),
      );
    }
    notifyListeners();
  }

  Future<void> runAnalysis() async {
    aiLoading = true;
    aiError = null;
    aiResultsVisible = false;
    notifyListeners();

    final locale = Localizations.localeOf(context);

    try {
      await _provider.runAIAnalysis(language: locale.languageCode);
      final hasAiOutputs = await loadResult();
      aiLoading = false;
      aiResultsVisible = hasAiOutputs;
      if (_provider.errorKey == 'error.aiAlreadyRun') {
        final l10n = AppLocalizations.of(context)!;
        aiError = l10n.errorAiAlreadyRun;
      }
    } catch (e) {
      aiLoading = false;
      aiError = e.toString();
      aiResultsVisible = false;
    }
    notifyListeners();
  }

  Future<void> runAgain() async {
    submittingAgain = true;
    aiResultsVisible = false;
    aiError = null;
    auditFromCache = false;
    notifyListeners();

    final url = _provider.result?.originalUrl ?? _provider.lastAuditedUrl ?? '';
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorNoUrl)),
      );
      submittingAgain = false;
      notifyListeners();
      return;
    }
    await _provider.startAudit(url, force: true);
    final newAuditId = _provider.result?.auditId;
    submittingAgain = false;

    if (newAuditId != null && newAuditId != auditId) {
      // Naviguj na nový result page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            auditId: newAuditId,
            onLocaleChange: onLocaleChange, // <-- správně předej callback!
          ),
        ),
      );
      return;
    }
    await loadResult();
    notifyListeners();
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

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
