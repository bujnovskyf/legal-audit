import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  final Locale currentLocale;
  final void Function(Locale) onLocaleChange;

  const LanguageSwitcher({
    super.key,
    required this.currentLocale,
    required this.onLocaleChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: l10n.changeLanguage, // lokalizované
      onSelected: (locale) => onLocaleChange(locale),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('cs'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'cs')
                const Icon(Icons.check, size: 18),
              const SizedBox(width: 4),
              Text(l10n.languageCzech),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, size: 18),
              const SizedBox(width: 4),
              Text(l10n.languageEnglish),
            ],
          ),
        ),
      ],
    );
  }
}
