import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audit_provider.dart';

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
  String? aiError; // speciální error pro AI analýzu

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResult();
    });
  }

  Future<void> _loadResult() async {
    final provider = context.read<AuditProvider>();
    await provider.refreshResult(widget.auditId);

    final urls = provider.result?.docUrls ?? {};
    controllers.forEach((key, ctrl) {
      ctrl.text = (urls[key] ?? '').toString();
    });
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _updateUrls() async {
    final provider = context.read<AuditProvider>();
    final newUrls = controllers.map((key, ctrl) => MapEntry(key, ctrl.text.trim()));
    await provider.updateDocumentUrls(newUrls);
    await _loadResult();
  }

  Future<void> _runAnalysis() async {
    setState(() {
      aiLoading = true;
      aiError = null;
    });
    final provider = context.read<AuditProvider>();
    await provider.runAIAnalysis();
    await _loadResult();
    // Pokud se vrátí chyba "AI analýza už byla provedena", zobrazíme info místo spinneru
    setState(() {
      aiLoading = false;
      if (provider.error != null &&
          provider.error!.toLowerCase().contains('ai analýza už byla provedena')) {
        aiError = provider.error;
      }
    });
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
                          ...controllers.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: TextField(
                                controller: entry.value,
                                decoration: InputDecoration(
                                  labelText: entry.key.replaceAll('_', ' ').toUpperCase(),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _updateUrls,
                            child: const Text('Aktualizovat URL dokumentů'),
                          ),
                          const SizedBox(height: 24),
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
                          if (aiError != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              aiError!,
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ],
                          const SizedBox(height: 24),
                          const Text(
                            'Compliance skóre:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            '${result.complianceScore}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          const Text('Chybějící dokumenty:'),
                          if (result.missingDocuments.isEmpty)
                            const Text('- Žádné')
                          else
                            ...result.missingDocuments.map((d) => Text('- $d')),
                          const SizedBox(height: 12),
                          const Text('Detekované trackery:'),
                          if (result.detectedTrackers.isEmpty)
                            const Text('- Žádné')
                          else
                            ...result.detectedTrackers.map((t) => Text('- $t')),
                          const SizedBox(height: 24),
                          const Text(
                            'Výsledky AI analýzy:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          _buildGrokOutput(result.grokOutputs, aiLoading),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildGrokOutput(Map<String, dynamic>? grokOutputs, bool loading) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
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
}
