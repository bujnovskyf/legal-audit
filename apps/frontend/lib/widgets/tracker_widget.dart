import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrackerWidget extends StatelessWidget {
  final dynamic tracker;

  const TrackerWidget(this.tracker, {super.key});

  Color _consentColor(dynamic consent, BuildContext context) {
    final theme = Theme.of(context);
    if (consent == true || consent == 'true') {
      return theme.colorScheme.error.withAlpha((0.13 * 255).round());
    }
    if (consent == false || consent == 'false') {
      return theme.colorScheme.primary.withAlpha((0.10 * 255).round());
    }
    return Colors.orange.withAlpha((0.13 * 255).round());
  }

  Color _consentIconColor(dynamic consent, BuildContext context) {
    final theme = Theme.of(context);
    if (consent == true || consent == 'true') {
      return theme.colorScheme.error;
    }
    if (consent == false || consent == 'false') {
      return theme.colorScheme.primary;
    }
    return Colors.orange;
  }

  IconData _consentIcon(dynamic consent) {
    if (consent == true || consent == 'true') {
      return Icons.warning_amber_rounded;
    }
    if (consent == false || consent == 'false') {
      return Icons.verified_user_rounded;
    }
    return Icons.help_outline_rounded;
  }

  String _consentText(dynamic consent, AppLocalizations l10n) {
    if (consent == true || consent == 'true') return l10n.consentCollects;
    if (consent == false || consent == 'false') return l10n.consentDoesNotCollect;
    return l10n.consentUnknown;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String name = '';
    dynamic consent;

    if (tracker is Map && tracker['name'] != null) {
      name = tracker['name'].toString();
      consent = tracker['consent'];
    } else if (tracker is String) {
      final regExp = RegExp(r'{\s*name:\s*([^,}]+),\s*consent:\s*([^}]+)\s*}');
      final match = regExp.firstMatch(tracker);
      if (match != null) {
        name = match.group(1)?.trim() ?? tracker;
        final consentStr = match.group(2)?.trim();
        if (consentStr == 'true') {
          consent = true;
        } else if (consentStr == 'false') {
          consent = false;
        } else {
          consent = null;
        }
      } else {
        name = tracker;
        consent = null;
      }
    } else {
      name = tracker.toString();
      consent = null;
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _consentColor(consent, context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isMobile
          // Mobile: Column layout, text under name
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        _consentIcon(consent),
                        color: _consentIconColor(consent, context),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.3,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.88 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _consentIconColor(consent, context).withAlpha((0.23 * 255).round()),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _consentText(consent, l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _consentIconColor(consent, context),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
              ],
            )

          // Desktop: Row layout, text vertically centered next to name
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    _consentIcon(consent),
                    color: _consentIconColor(consent, context),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.3,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.88 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _consentIconColor(consent, context).withAlpha((0.23 * 255).round()),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _consentText(consent, l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _consentIconColor(consent, context),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}
