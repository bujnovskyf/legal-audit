// Displays compliance score and issues found.
import 'package:flutter/material.dart';
import '../models/audit_result.dart';

class AuditCard extends StatelessWidget {
  final AuditResult result;
  const AuditCard({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Score: ${result.complianceScore}'),
            // TODO: list missingDocuments and detectedTrackers
          ],
        ),
      ),
    );
  }
}
