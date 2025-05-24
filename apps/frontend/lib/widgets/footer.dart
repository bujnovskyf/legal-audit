import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'about_dialog_content.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.aboutProject,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        content: const AboutDialogContent(),
        actions: [
          TextButton(
            child: Text(l10n.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(fontSize: 13);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showAboutDialog(context),
              splashColor: theme.colorScheme.primary.withAlpha((0.3 * 255).round()),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  l10n.about,
                  style: textStyle?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Divider(
            thickness: 1,
            color: theme.dividerColor,
            height: 24,
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.builtBy} ', style: textStyle),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _launchUrl('https://labs.narrativva.com/'),
                splashColor: theme.colorScheme.secondary.withAlpha((0.3 * 255).round()),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    'Narrativva Labs',
                    style: textStyle?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _launchUrl('https://github.com/bujnovskyf/legal-audit'),
            splashColor: theme.colorScheme.secondary.withAlpha((0.3 * 255).round()),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_border_rounded, color: theme.colorScheme.secondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.starOn} GitHub',
                    style: textStyle?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      letterSpacing: 0.25,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('© 2025 ', style: textStyle),
              const Text('❤️', style: TextStyle(fontSize: 14)),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _launchUrl('https://narrativva.com'),
                splashColor: theme.colorScheme.secondary.withAlpha((0.3 * 255).round()),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    'Narrativva',
                    style: textStyle?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
