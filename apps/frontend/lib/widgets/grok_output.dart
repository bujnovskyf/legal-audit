import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GrokOutputWidget extends StatelessWidget {
  final Map<String, dynamic>? grokOutputs;
  final bool loading;
  final AppLocalizations l10n;

  const GrokOutputWidget({
    super.key,
    required this.grokOutputs,
    required this.loading,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (grokOutputs == null || grokOutputs!.isEmpty) {
      return Text(l10n.noResults);
    }

    final docs = {
      l10n.privacyPolicyTitle: grokOutputs!['privacy_policy_url'],
      l10n.cookiePolicyTitle: grokOutputs!['cookie_policy_url'],
      l10n.termsOfUseTitle: grokOutputs!['terms_of_use_url'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: docs.entries.map((entry) {
        final value = entry.value?.toString().trim() ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              if (value.isEmpty)
                Text(l10n.docNotFound, style: const TextStyle(fontStyle: FontStyle.italic))
              else
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(top: 0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MarkdownBody(
                        data: value,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          p: const TextStyle(fontSize: 14),
                          code: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            backgroundColor: Colors.transparent,
                          ),
                          strong: const TextStyle(fontWeight: FontWeight.bold),
                          blockquote: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                          listBullet: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: IconButton(
                        icon: const Icon(Icons.copy, size: 22),
                        tooltip: l10n.copiedToClipboard,
                        color: Colors.green.shade900,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: value));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.copy)),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
