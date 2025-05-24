import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'about_dialog_content.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  void _launchUrl(String url) async {
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
        title: Text(l10n.aboutProject),
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
    final l10n = AppLocalizations.of(context)!;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () => _showAboutDialog(context),
              child: Text(
                l10n.about,
                style: textStyle?.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.builtBy} ', style: textStyle),
              InkWell(
                onTap: () => _launchUrl('https://labs.narrativva.com/'),
                child: Text(
                  'Narrativva Labs',
                  style: textStyle?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _launchUrl('https://github.com/bujnovskyf/legal-audit'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${l10n.starOn} ', style: textStyle),
                Text(
                  'GitHub',
                  style: textStyle?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('© 2025 ', style: textStyle),
              const Text('❤️', style: TextStyle(fontSize: 16)),
              InkWell(
                onTap: () => _launchUrl('https://narrativva.com'),
                child: Text(
                  ' Narrativva',
                  style: textStyle?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
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
