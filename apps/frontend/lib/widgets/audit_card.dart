import 'package:flutter/material.dart';
import '../models/audit_result.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuditCard extends StatelessWidget {
  final AuditResult result;
  const AuditCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.compliance}: ${result.complianceScore}%'),
            const SizedBox(height: 12),
            Text('${l10n.missingDocuments}:'),
            for (var d in result.missingDocuments) Text('- $d'),
            const SizedBox(height: 12),
            Text('${l10n.detectedTrackers}:'),
            for (var t in result.detectedTrackers) Text('- $t'),
          ],
        ),
      ),
    );
  }
}
