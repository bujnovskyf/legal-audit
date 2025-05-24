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
    if (loading && (grokOutputs == null || grokOutputs!.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (grokOutputs == null || grokOutputs!.isEmpty) {
      return _InfoCard(
        icon: Icons.info_outline_rounded,
        text: l10n.noResults,
      );
    }

    final docs = {
      l10n.privacyPolicyTitle: grokOutputs!['privacy_policy_url'],
      l10n.cookiePolicyTitle: grokOutputs!['cookie_policy_url'],
      l10n.termsOfUseTitle: grokOutputs!['terms_of_use_url'],
    };

    final double screenWidth = MediaQuery.of(context).size.width;
    final double blockPadding = screenWidth < 600 ? 14 : 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: docs.entries.map((entry) {
        final value = entry.value?.toString().trim() ?? '';
        final isEmpty = value.isEmpty;

        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: const Color(0xFF18181B),
                    ),
              ),
              const SizedBox(height: 7),
              isEmpty
                  ? _InfoCard(
                      icon: Icons.info_outline_rounded,
                      text: l10n.docNotFound,
                    )
                  : Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(blockPadding),
                          margin: const EdgeInsets.only(top: 0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFe5fbea),
                                Color(0xFFf8fafd),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(18),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: MarkdownBody(
                            data: value,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              h1: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 19,
                                  ),
                              h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                              h3: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                              p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                              code: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                backgroundColor: Color(0xFFF1F5F9),
                              ),
                              strong: const TextStyle(fontWeight: FontWeight.bold),
                              blockquote: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                              listBullet: const TextStyle(fontSize: 14),
                              a: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: _CopyButton(value: value, l10n: l10n),
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

// Decentní info card (pro prázdný výstup)
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500], size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// Moderní, menší, decentní copy button (se snackbar notifikací)
class _CopyButton extends StatelessWidget {
  final String value;
  final AppLocalizations l10n;
  const _CopyButton({required this.value, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: value));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.copy),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            Icons.copy_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
