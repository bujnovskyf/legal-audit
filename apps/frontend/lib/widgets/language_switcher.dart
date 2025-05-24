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
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: PopupMenuButton<Locale>(
        icon: Icon(Icons.language, color: primaryColor, size: 27),
        tooltip: l10n.changeLanguage,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: Colors.white,
        itemBuilder: (context) => [
          _LangMenuItem(
            locale: const Locale('cs'),
            currentLocale: currentLocale,
            text: l10n.languageCzech,
            primaryColor: primaryColor,
            onSelect: onLocaleChange,
          ),
          _LangMenuItem(
            locale: const Locale('en'),
            currentLocale: currentLocale,
            text: l10n.languageEnglish,
            primaryColor: primaryColor,
            onSelect: onLocaleChange,
          ),
        ],
        onSelected: (locale) => onLocaleChange(locale),
      ),
    );
  }
}

class _LangMenuItem extends PopupMenuEntry<Locale> {
  final Locale locale;
  final Locale currentLocale;
  final String text;
  final Color primaryColor;
  final void Function(Locale) onSelect;

  const _LangMenuItem({
    required this.locale,
    required this.currentLocale,
    required this.text,
    required this.primaryColor,
    required this.onSelect,
  });

  @override
  double get height => 44;

  @override
  bool represents(Locale? value) => value == locale;

  @override
  State<_LangMenuItem> createState() => _LangMenuItemState();
}

class _LangMenuItemState extends State<_LangMenuItem> {
  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.locale.languageCode == widget.currentLocale.languageCode;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.pop(context, widget.locale);
        widget.onSelect(widget.locale);
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: isSelected
            ? BoxDecoration(
                color: widget.primaryColor.withAlpha((0.08 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: widget.primaryColor, size: 20)
            else
              const SizedBox(width: 20),
            const SizedBox(width: 10),
            Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? widget.primaryColor : Colors.black,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
