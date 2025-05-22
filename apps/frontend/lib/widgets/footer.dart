import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'about_dialog_content.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('O projektu'),
        content: const AboutDialogContent(),
        actions: [
          TextButton(
            child: const Text('Zavřít'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // About jako první řádek
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () => _showAboutDialog(context),
              child: Text(
                'About',
                style: textStyle?.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Built by
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔧 ', style: TextStyle(fontSize: 16)),
              Text('Built by ', style: textStyle),
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
          // GitHub
          InkWell(
            onTap: () => _launchUrl('https://github.com/bujnovskyf/legal-audit'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐ ', style: TextStyle(fontSize: 16)),
                Text('Star us on ', style: textStyle),
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
          // Copyright
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
