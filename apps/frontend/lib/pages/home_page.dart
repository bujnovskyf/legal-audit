import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/audit_provider.dart';
import '../services/url_validator.dart';
import 'result_page.dart';
import '../widgets/footer.dart';
import '../widgets/language_switcher.dart';

class HomePage extends StatefulWidget {
  final void Function(Locale) onLocaleChange;

  const HomePage({super.key, required this.onLocaleChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _submit({bool force = false}) async {
    String input = UrlValidator.normalize(_controller.text);
    _controller.text = input;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final provider = context.read<AuditProvider>();

    await provider.startAudit(_controller.text.trim(), force: force);

    setState(() => _loading = false);

    final auditId = provider.result?.auditId;

    if (!mounted) return;
    // Používáme errorKey, ne error!
    if (provider.errorKey == null && auditId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            auditId: auditId,
            onLocaleChange: widget.onLocaleChange,
          ),
        ),
      );
    } else if (provider.errorKey != null) {
      final l10n = AppLocalizations.of(context)!;
      final errorText = _mapErrorKeyToMessage(l10n, provider.errorKey!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText)),
      );
    }
  }

  String _mapErrorKeyToMessage(AppLocalizations l10n, String errorKey) {
    switch (errorKey) {
      case 'error.500':
        return l10n.error500;
      case 'error.404':
        return l10n.error404;
      case 'error.429':
        return l10n.error429;
      case 'error.network':
        return l10n.errorNetwork('');
      case 'error.aiAlreadyRun':
        return l10n.errorAiAlreadyRun;
      case 'error.auditIdNull':
        return l10n.errorAuditIdNull;
      case 'error.empty':
        return l10n.urlEmpty;
      case 'error.invalid':
        return l10n.urlInvalid;
      default:
        return l10n.errorGeneric(errorKey);
    }
  }

  String? _localizedUrlValidator(String? value, AppLocalizations l10n) {
    final errorKey = UrlValidator.validate(value);
    if (errorKey == null) return null;
    return _mapErrorKeyToMessage(l10n, errorKey);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final lastUrl = provider.lastAuditedUrl;
    if ((_controller.text.isEmpty || _controller.text != lastUrl) &&
        (lastUrl != null && lastUrl.isNotEmpty)) {
      _controller.text = lastUrl;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          LanguageSwitcher(
            currentLocale: locale,
            onLocaleChange: widget.onLocaleChange,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.enterUrl,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.urlLabel,
                    hintText: l10n.urlHint,
                  ),
                  validator: (value) => _localizedUrlValidator(value, l10n),
                  keyboardType: TextInputType.url,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _submit(),
                        child: Text(l10n.startAudit),
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
