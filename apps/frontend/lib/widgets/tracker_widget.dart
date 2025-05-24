import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrackerWidget extends StatelessWidget {
  final dynamic tracker;

  const TrackerWidget(this.tracker, {super.key});

  Color _consentColor(dynamic consent) {
    if (consent == true || consent == 'true') return Colors.red.shade100;
    if (consent == false || consent == 'false') return Colors.green.shade100;
    return Colors.orange.shade100;
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _consentColor(consent),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Text(
            _consentText(consent, l10n),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
