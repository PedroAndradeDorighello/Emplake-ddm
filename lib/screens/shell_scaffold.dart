import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../router/app_router.dart';
import '../theme/screen_scale.dart';
import '../widgets/help_dialog.dart';

class ShellScaffold extends ConsumerStatefulWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold> {
  int _indexFor(String loc) {
    if (loc.startsWith('/progress')) return 1;
    if (loc.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loc = GoRouterState.of(context).uri.toString();
    final index = _indexFor(loc);
    final scheme = Theme.of(context).colorScheme;
    final prefs = ref.watch(sharedPrefsProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      persistRoute(prefs, loc);
    });

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CurvedNavigationBar(
        key: ValueKey(index),
        index: index,
        height: ScreenScale.of(context).compact ? 52 : 64,
        backgroundColor: Colors.transparent,
        color: scheme.primary,
        buttonBackgroundColor: scheme.secondary,
        animationDuration: const Duration(milliseconds: 280),
        items: [
          Tooltip(
            message: l10n.navGame,
            child: const Icon(Icons.sports_esports, color: Colors.white),
          ),
          Tooltip(
            message: l10n.navProgress,
            child: const Icon(Icons.emoji_events_outlined, color: Colors.white),
          ),
          Tooltip(
            message: l10n.navHelp,
            child: const Icon(Icons.help_outline, color: Colors.white),
          ),
          Tooltip(
            message: l10n.navSettings,
            child: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
        onTap: (i) async {
          switch (i) {
            case 0:
              context.go('/play');
            case 1:
              context.go('/progress');
            case 2:
              await showHelpDialog(context);
              if (mounted) setState(() {});
            case 3:
              context.go('/settings');
          }
        },
      ),
    );
  }
}
