import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

Future<void> showHelpDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: SelectableText(l10n.helpTitle),
      content: SingleChildScrollView(child: SelectableText(l10n.helpBody)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
        ),
      ],
    ),
  );
}
