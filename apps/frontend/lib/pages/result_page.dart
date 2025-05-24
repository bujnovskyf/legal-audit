import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/language_switcher.dart';
import '../providers/audit_provider.dart';
import '../providers/result_page_controller.dart';
import '../widgets/footer.dart';
import '../widgets/tracker_widget.dart';
import '../widgets/grok_output.dart';
import '../widgets/run_again_dialog.dart';

class ResultPage extends StatelessWidget {
  final String auditId;
  final void Function(Locale) onLocaleChange;

  const ResultPage({
    super.key,
    required this.auditId,
    required this.onLocaleChange,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth < 600 ? 12 : 32;
    final double maxCardWidth = 700.0;

    return ChangeNotifierProvider<ResultPageController>(
      create: (ctx) => ResultPageController(
        context: ctx,
        auditId: auditId,
        onLocaleChange: onLocaleChange,
      ),
      builder: (context, _) {
        final controller = context.watch<ResultPageController>();
        final provider = context.watch<AuditProvider>();
        final result = provider.result;
        final l10n = AppLocalizations.of(context)!;
        final locale = Localizations.localeOf(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: [
              LanguageSwitcher(
                currentLocale: locale,
                onLocaleChange: onLocaleChange,
              ),
            ],
          ),
          body: Center(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.errorKey != null && controller.aiError == null
                    ? Center(
                        child: Text(
                          '${l10n.error}: ${controller.mapErrorKeyToMessage(l10n, provider.errorKey)}',
                        ),
                      )
                    : result == null
                        ? Center(child: Text(l10n.noResultsAvailable))
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding, vertical: 32),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxCardWidth),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (provider.fromCache == true)
                                      _CacheInfoBanner(
                                        controller: controller,
                                        l10n: l10n,
                                      ),
                                    _SectionCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _SectionTitle(l10n.docUrls),
                                          const SizedBox(height: 6),
                                          ...controller.controllers.entries.map(
                                            (entry) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 6),
                                              child: Focus(
                                                onFocusChange: (hasFocus) {
                                                  if (!hasFocus) {
                                                    controller.updateUrlField(entry.key);
                                                  }
                                                },
                                                child: TextField(
                                                  controller: entry.value,
                                                  decoration: InputDecoration(
                                                    labelText: entry.key.replaceAll('_', ' ').toUpperCase(),
                                                  ),
                                                  onSubmitted: (_) => controller.updateUrlField(entry.key),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _SectionCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _SectionTitle(l10n.missingDocuments),
                                          result.missingDocuments.isEmpty
                                              ? Text('- ${l10n.none}')
                                              : Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: result.missingDocuments
                                                      .map((d) => Text('- $d'))
                                                      .toList(),
                                                ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _SectionCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _SectionTitle(l10n.detectedTrackers),
                                          result.detectedTrackers.isEmpty
                                              ? Text('- ${l10n.none}')
                                              : Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: result.detectedTrackers
                                                      .map((t) => TrackerWidget(t))
                                                      .toList(),
                                                ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    _SectionCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _SectionTitle(l10n.aiAnalysis),
                                          if (provider.fromCache == true && !controller.aiResultsVisible)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                l10n.aiNotRunInLastAudit,
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          Row(
                                            children: [
                                              Icon(Icons.info_outline,
                                                  size: 15, color: Colors.grey.shade600),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  l10n.aiLanguageInfo(
                                                    locale.languageCode == 'cs'
                                                        ? l10n.languageCzech
                                                        : l10n.languageEnglish,
                                                  ),
                                                  style: const TextStyle(
                                                      fontSize: 12, color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: _GradientButton(
                                              onPressed: (controller.aiLoading ||
                                                      controller.aiResultsVisible ||
                                                      provider.fromCache == true)
                                                  ? null
                                                  : controller.runAnalysis,
                                              text: controller.aiLoading
                                                  ? l10n.analyzing
                                                  : l10n.runAiAnalysis,
                                              icon: Icons.auto_awesome,
                                              enabled: !(controller.aiLoading ||
                                                  controller.aiResultsVisible ||
                                                  provider.fromCache == true),
                                            ),
                                          ),
                                          if (controller.aiResultsVisible || controller.aiLoading)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 28, bottom: 8),
                                              child: GrokOutputWidget(
                                                grokOutputs: result.grokOutputs,
                                                loading: controller.aiLoading,
                                                l10n: l10n,
                                              ),
                                            ),
                                          if (controller.aiError != null) ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              controller.aiError!,
                                              style: const TextStyle(
                                                  color: Colors.orange, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    const AppFooter(),
                                  ],
                                ),
                              ),
                            ),
                          ),
          ),
        );
      },
    );
  }
}

// Moderní karta s rounded rohy, light stínem a bílým podkladem
class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: child,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: const Color(0xFF18181B),
          ),
    );
  }
}

// Banner s informací o cache a "Run Again"
class _CacheInfoBanner extends StatelessWidget {
  final ResultPageController controller;
  final AppLocalizations l10n;

  const _CacheInfoBanner({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.cacheInfo,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: controller.submittingAgain
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => RunAgainDialog(
                        isLoading: controller.submittingAgain,
                        onConfirm: () async {
                          await controller.runAgain();
                        },
                      ),
                    );
                  },
            child: controller.submittingAgain
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.runAgain),
          ),
        ],
      ),
    );
  }
}

// Gradientové tlačítko
class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool enabled;

  const _GradientButton({
    required this.onPressed,
    required this.text,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      elevation: enabled ? 6 : 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: enabled
                ? const LinearGradient(
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF06b6d4), // modrozelená (cyan-400)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: enabled ? null : Colors.grey.shade300,
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0x5522C55E),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
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
                        fontSize: 18,
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
