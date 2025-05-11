// Purpose: Display compliance score, missing docs, and trackers.
import 'package:flutter/material.dart';
import '../models/audit_result.dart';

class AuditCard extends StatelessWidget {
  final AuditResult result;
  const AuditCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compliance: ${result.complianceScore}%'),
            const SizedBox(height: 12),
            const Text('Missing Documents:'),
            for (var d in result.missingDocuments) Text('- $d'),
            const SizedBox(height: 12),
            const Text('Trackers Detected:'),
            for (var t in result.detectedTrackers) Text('- $t'),
          ],
        ),
      ),
    );
  }
}