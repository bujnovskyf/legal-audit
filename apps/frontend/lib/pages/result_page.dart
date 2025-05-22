import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audit_provider.dart';
import '../widgets/footer.dart';

class ResultPage extends StatefulWidget {
  final String auditId;
  const ResultPage({super.key, required this.auditId});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final Map<String, TextEditingController> controllers = {
    'privacy_policy_url': TextEditingController(),
    'cookie_policy_url': TextEditingController(),
    'terms_of_use_url': TextEditingController(),
  };

  bool aiLoading = false;
  bool aiResultsVisible = false;
  String? aiError;
  bool submittingAgain = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadResult());
  }

  Future<void> _loadResult() async {
    final provider = context.read<AuditProvider>();
    await provider.refreshResult(widget.auditId);
    final urls = provider.result?.docUrls ?? {};
    controllers.forEach((key, ctrl) {
      ctrl.text = (urls[key] ?? '').toString();
    });
    final grok = provider.result?.grokOutputs;
    if (grok != null && grok.isNotEmpty && mounted) {
      setState(() {
        aiResultsVisible = true;
      });
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _updateUrlField(String key) async {
    final provider = context.read<AuditProvider>();
    final newUrls = controllers.map((k, ctrl) => MapEntry(k, ctrl.text.trim()));
    try {
      await provider.updateDocumentUrls(newUrls, silent: true);
    } catch (e) {}
  }

  Future<void> _runAnalysis() async {
    setState(() {
      aiLoading = true;
      aiError = null;
    });
    final provider = context.read<AuditProvider>();
    await provider.runAIAnalysis();
    await _loadResult();
    setState(() {
      aiLoading = false;
      aiResultsVisible = true;
      if (provider.error != null &&
          provider.error!.toLowerCase().contains('ai analýza už byla provedena')) {
        aiError = provider.error;
      }
    });
  }

  Future<void> _runAgain() async {
    setState(() => submittingAgain = true);
    final provider = context.read<AuditProvider>();
    final url = provider.result?.originalUrl 
        ?? provider.lastAuditedUrl 
        ?? '';

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chyba: Chybí URL pro opakovaný audit.')),
      );
      setState(() => submittingAgain = false);
      return;
    }
    await provider.startAudit(url, force: true);
    await _loadResult();
    setState(() => submittingAgain = false);
  }

  Color _consentColor(dynamic consent) {
    if (consent == true || consent == 'true') return Colors.red.shade100;
    if (consent == false || consent == 'false') return Colors.green.shade100;
    return Colors.orange.shade100;
  }

  String _consentText(dynamic consent) {
    if (consent == true || consent == 'true') return "SBÍRÁ DATA JEŠTĚ PŘED SOUHLASEM (špatně)";
    if (consent == false || consent == 'false') return "NESBÍRÁ DATA BEZ SOUHLASU (dobře)";
    return "NELZE VYHODNOTIT (možná špatně nastavené)";
  }

  Widget _trackerWidget(dynamic t) {
    String name = '';
    dynamic consent;

    // Bezpečně pro Map, String i jiné typy
    if (t is Map && t['name'] != null) {
      name = t['name'].toString();
      consent = t['consent'];
    } else if (t is String) {
      // Zkusím najít pattern {name: ..., consent: ...}
      final regExp = RegExp(r'{\s*name:\s*([^,}]+),\s*consent:\s*([^}]+)\s*}');
      final match = regExp.firstMatch(t);
      if (match != null) {
        name = match.group(1)?.trim() ?? t;
        final consentStr = match.group(2)?.trim();
        if (consentStr == 'true') consent = true;
        else if (consentStr == 'false') consent = false;
        else consent = null;
      } else {
        name = t;
        consent = null;
      }
    } else {
      name = t.toString();
      consent = null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _consentColor(consent),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Text(
            _consentText(consent),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGrokOutput(Map<String, dynamic>? grokOutputs, bool loading) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (grokOutputs == null || grokOutputs.isEmpty) {
      return const Text('Žádné výsledky');
    }
    final docs = {
      'Zásady ochrany osobních údajů': grokOutputs['privacy_policy_url'],
      'Zásady cookies': grokOutputs['cookie_policy_url'],
      'Obchodní podmínky': grokOutputs['terms_of_use_url'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: docs.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              if (entry.value == null || (entry.value is String && (entry.value as String).trim().isEmpty))
                const Text('Dokument nebyl zadán nebo nebyl nalezen.', style: TextStyle(fontStyle: FontStyle.italic))
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey.shade100,
                  width: double.infinity,
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final result = provider.result;

    return Scaffold(
      appBar: AppBar(title: const Text('Výsledek auditu')),
      body: provider.loading && !aiLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && aiError == null
              ? Center(child: Text('Chyba: ${provider.error!}'))
              : result == null
                  ? const Center(child: Text('Výsledky nejsou k dispozici.'))
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
                                      'Toto je uložený výsledek auditu z poslední hodiny. '
                                      'Pokud potřebujete, můžete spustit audit znovu.',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: submittingAgain
                                        ? null
                                        : () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('Opravdu spustit audit znovu?'),
                                                content: const Text(
                                                  'Spuštění nového auditu této stránky stojí reálné peníze (API a serverové náklady). '
                                                  'Použij tuto možnost pouze pokud opravdu potřebuješ provést nový audit.\n\n'
                                                  'Chceš opravdu pokračovat?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: const Text('Zrušit'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();
                                                      await _runAgain();
                                                    },
                                                    child: const Text('Ano, spustit znovu'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                    child: submittingAgain
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text('Spustit znovu'),
                                  ),
                                ],
                              ),
                            ),
                          // URL k dokumentům s autosave
                          const Text(
                            'URL k dokumentům:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          ...controllers.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (!hasFocus) {
                                    _updateUrlField(entry.key);
                                  }
                                },
                                child: TextField(
                                  controller: entry.value,
                                  decoration: InputDecoration(
                                    labelText: entry.key.replaceAll('_', ' ').toUpperCase(),
                                    border: const OutlineInputBorder(),
                                  ),
                                  onSubmitted: (_) => _updateUrlField(entry.key),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Chybějící dokumenty:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          if (result.missingDocuments.isEmpty)
                            const Text('- Žádné')
                          else
                            ...result.missingDocuments.map((d) => Text('- $d')),
                          const SizedBox(height: 24),
                          const Text(
                            'Detekované trackery:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          if (result.detectedTrackers.isEmpty)
                            const Text('- Žádné')
                          else
                            ...result.detectedTrackers.map(_trackerWidget),
                          const SizedBox(height: 28),
                          ElevatedButton(
                            onPressed: aiLoading ? null : _runAnalysis,
                            child: aiLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Spustit AI analýzu'),
                          ),
                          if (aiResultsVisible || aiLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 32, bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Výsledky AI analýzy:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildGrokOutput(result.grokOutputs, aiLoading),
                                ],
                              ),
                            ),
                          if (aiError != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              aiError!,
                              style: const TextStyle(
                                  color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ],
                          const SizedBox(height: 32),
                          const AppFooter(),
                        ],
                      ),
                    ),
    );
  }
}
