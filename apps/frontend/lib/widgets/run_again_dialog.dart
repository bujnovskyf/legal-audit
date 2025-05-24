import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RunAgainDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  const RunAgainDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 28)
            : const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.refresh_rounded, size: 38, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              l10n.dialogRunAgainTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.dialogRunAgainContent,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[800],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            if (isMobile) ...[
              // Mobilní verze: Zrušit vlevo, Spustit uprostřed (jak bylo)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              onCancel?.call();
                              Navigator.of(context).pop();
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              onConfirm();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          letterSpacing: -0.5,
                        ),
                        minimumSize: const Size.fromHeight(52),
                        elevation: 6,
                        shadowColor: theme.colorScheme.primary.withAlpha(128),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(l10n.runAgain),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Desktop verze: Obě tlačítka vedle sebe, uprostřed celku
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            onCancel?.call();
                            Navigator.of(context).pop();
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 140, maxWidth: 180),
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              onConfirm();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          letterSpacing: -0.5,
                        ),
                        minimumSize: const Size.fromHeight(52),
                        elevation: 6,
                        shadowColor: theme.colorScheme.primary.withAlpha((0.5 * 255).round()),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(l10n.runAgain),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
