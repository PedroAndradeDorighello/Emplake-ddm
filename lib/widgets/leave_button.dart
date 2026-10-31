import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class LeaveButton extends ConsumerWidget {
  const LeaveButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return TextButton(
      onPressed: () async {
        await ref.read(authProvider.notifier).signOut();
        if (context.mounted) context.go('/login');
      },
      child: Text(l10n.signOut),
    );
  }
}
