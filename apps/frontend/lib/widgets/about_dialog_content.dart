import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutDialogContent extends StatelessWidget {
  const AboutDialogContent({super.key});

  void _launchMail() {
    launchUrl(Uri.parse('mailto:info@narrativva.com'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SelectableText.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(text: l10n.aboutText),
          TextSpan(
            text: 'info@narrativva.com',
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = _launchMail,
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
