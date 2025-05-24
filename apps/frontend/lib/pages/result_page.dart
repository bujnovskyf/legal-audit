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
    return ChangeNotifierProvider<ResultPageController>(
      create: (ctx) => ResultPageController(
        context: ctx, 
        auditId: auditId,
        onLocaleChange: onLocaleChange
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
          body: controller.isLoading
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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (provider.fromCache == true)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
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
                                ),
                              Text(
                                l10n.docUrls,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
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
                                        border: const OutlineInputBorder(),
                                      ),
                                      onSubmitted: (_) => controller.updateUrlField(entry.key),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.missingDocuments,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              if (result.missingDocuments.isEmpty)
                                Text('- ${l10n.none}')
                              else
                                ...result.missingDocuments.map((d) => Text('- $d')),
                              const SizedBox(height: 24),
                              Text(
                                l10n.detectedTrackers,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              if (result.detectedTrackers.isEmpty)
                                Text('- ${l10n.none}')
                              else
                                ...result.detectedTrackers.map((t) => TrackerWidget(t)),
                              const SizedBox(height: 28),
                              ElevatedButton(
                                onPressed: (controller.aiLoading ||
                                        controller.aiResultsVisible ||
                                        provider.fromCache == true)
                                    ? null
                                    : controller.runAnalysis,
                                child: controller.aiLoading
                                    ? const SizedBox(
                                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(l10n.runAiAnalysis),
                              ),
                              if (provider.fromCache == true && !controller.aiResultsVisible)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    l10n.aiNotRunInLastAudit,
                                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.info_outline, size: 15, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      l10n.aiLanguageInfo(
                                        locale.languageCode == 'cs'
                                            ? l10n.languageCzech
                                            : l10n.languageEnglish,
                                      ),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              if (controller.aiResultsVisible || controller.aiLoading)
                                Padding(
                                  padding: const EdgeInsets.only(top: 32, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.aiAnalysisResults,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      const SizedBox(height: 12),
                                      GrokOutputWidget(
                                        grokOutputs: result.grokOutputs,
                                        loading: controller.aiLoading,
                                        l10n: l10n,
                                      ),
                                    ],
                                  ),
                                ),
                              if (controller.aiError != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  controller.aiError!,
                                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ],
                              const SizedBox(height: 32),
                              const AppFooter(),
                            ],
                          ),
                        ),
        );
      },
    );
  }
}
