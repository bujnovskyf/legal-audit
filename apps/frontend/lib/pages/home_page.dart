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

    final double screenWidth = MediaQuery.of(context).size.width;
    // Větší paddingy na desktopu, menší na mobilu
    final double horizontalPadding = screenWidth < 600 ? 16 : 40;

    // Maximální šířka karty (na desktopu se nikdy neroztáhne do 100%)
    final double maxCardWidth = 480;

    // Adaptivní velikost headline (větší na desktopu)
    final double headlineFontSize = screenWidth < 600 ? 28 : 36;

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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48, horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxCardWidth,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).round()),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFe5fbea), // světle zelená
                          Color(0xFFf8fafd), // téměř bílá
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth < 600 ? 36 : 48,
                        horizontal: screenWidth < 600 ? 18 : 36,
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.homeHeadline,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: headlineFontSize,
                                  color: const Color(0xFF18181B),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.homeSubtitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w400,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    labelText: l10n.urlLabel,
                                    hintText: l10n.urlHint,
                                    prefixIcon: const Icon(Icons.link, color: Color(0xFF22C55E)),
                                  ),
                                  validator: (value) => _localizedUrlValidator(value, l10n),
                                  keyboardType: TextInputType.url,
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: double.infinity,
                                  child: _loading
                                      ? const Center(child: CircularProgressIndicator())
                                      : _GradientButton(
                                          onPressed: () => _submit(),
                                          text: l10n.startAudit,
                                          icon: Icons.search,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // (volitelně další sekce nebo "Jak to funguje")
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

// Vlastní gradientové tlačítko – stejně responzivní
class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;

  const _GradientButton({
    required this.onPressed,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonFontSize = screenWidth < 600 ? 16 : 18;

    return Material(
      borderRadius: BorderRadius.circular(24),
      elevation: 6,
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF22C55E),
                Color(0xFF06b6d4), // modrozelená (cyan-400)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x5522C55E),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                Text(
                  text,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: buttonFontSize,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
