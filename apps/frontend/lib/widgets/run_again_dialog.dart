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
    return AlertDialog(
      title: Text(l10n.dialogRunAgainTitle),
      content: Text(l10n.dialogRunAgainContent),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  onCancel?.call();
                  Navigator.of(context).pop();
                },
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
          child: isLoading
              ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.runAgain),
        ),
      ],
    );
  }
}
