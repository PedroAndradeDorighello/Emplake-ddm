import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/game_screen.dart';
import '../screens/login_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shell_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authProvider, (previous, next) => refresh.value++);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: _restore(prefs) ?? '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loggingIn = state.matchedLocation == '/login';
      if (auth == null && !loggingIn) return '/login';
      if (auth != null && loggingIn) return '/play';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/play',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GameScreen(),
            ),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProgressScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

String? _restore(SharedPreferences prefs) {
  final path = prefs.getString('last_route');
  if (path == null || path == '/login') return null;
  return path;
}

Future<void> persistRoute(SharedPreferences prefs, String location) async {
  if (location == '/login') return;
  await prefs.setString('last_route', location);
}

