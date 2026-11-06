import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'router/app_router.dart';
import 'services/progress_repository.dart';
import 'theme/app_theme.dart';
import 'theme/screen_scale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  final localRepo = LocalProgressRepository(prefs);
  final ProgressRepository progressRepo = firebaseReady
      ? FirestoreProgressRepository(FirebaseFirestore.instance, localRepo)
      : localRepo;

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        firebaseReadyProvider.overrideWithValue(firebaseReady),
        progressRepositoryProvider.overrideWithValue(progressRepo),
      ],
      child: const EmplakeApp(),
    ),
  );
}

class EmplakeApp extends ConsumerWidget {
  const EmplakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    ref.listen(authProvider, (previous, next) {
      if (next == null || next.isGuest || previous?.uid == next.uid) return;
      final uid = next.uid;
      Future<void>(() async {
        final route = await ref.read(settingsProvider.notifier).pullProfile(uid);
        if (route != null) ref.read(routerProvider).go(route);
      });
    });

    return MaterialApp.router(
      title: 'Emplake',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        FirebaseUILocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      themeMode: settings.themeMode,
      theme: buildTheme(settings, Brightness.light),
      darkTheme: buildTheme(settings, Brightness.dark),
      builder: (context, child) {
        final scale = ScreenScale.of(context);
        final user = settings.fontSize / 16;
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(user * scale.text),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
