import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

Future<void> showHelpDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.helpTitle),
      content: SingleChildScrollView(child: Text(l10n.helpBody)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
