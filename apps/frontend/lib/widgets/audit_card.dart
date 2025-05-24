import 'package:flutter/material.dart';
import '../models/audit_result.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuditCard extends StatelessWidget {
  final AuditResult result;
  const AuditCard({super.key, required this.result});

  Color _getScoreColor(double score) {
    if (score >= 85.0) return const Color(0xFF22C55E); // zelená
    if (score >= 60.0) return const Color(0xFFFACC15); // žlutá
    return const Color(0xFFF43F5E); // červená
  }

  String _getScoreLabel(double score, AppLocalizations l10n) {
    if (score >= 85.0) return l10n.statusCompliant;
    if (score >= 60.0) return l10n.statusAttention;
    return l10n.statusNonCompliant;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 85.0) return Icons.verified;
    if (score >= 60.0) return Icons.warning_amber_rounded;
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double score = result.complianceScore;
    final Color scoreColor = _getScoreColor(score);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scoreColor.withAlpha(38),
                  ),
                  child: Icon(
                    _getScoreIcon(score),
                    color: scoreColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.compliance}: ${score.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: scoreColor.withAlpha(31),
                      ),
                      child: Text(
                        _getScoreLabel(score, l10n),
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Chybějící dokumenty
            Text(
              l10n.missingDocuments,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
            ),
            if (result.missingDocuments.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 2),
                child: Text(
                  '- ${l10n.none}',
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w400),
                ),
              )
            else
              ...result.missingDocuments.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(top: 2, left: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.file_present_rounded, size: 18, color: Color(0xFFF59E42)), // oranžová
                      const SizedBox(width: 6),
                      Flexible(child: Text(d, style: const TextStyle(fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text(
              l10n.detectedTrackers,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
            ),
            if (result.detectedTrackers.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 2),
                child: Text(
                  '- ${l10n.none}',
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w400),
                ),
              )
            else
              ...result.detectedTrackers.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(top: 2, left: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_rounded, size: 18, color: Color(0xFF06b6d4)), // cyan
                      const SizedBox(width: 6),
                      Flexible(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
