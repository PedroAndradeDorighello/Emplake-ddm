import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/team.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

const _googleWebClientId =
    '726124199747-g6glgjqjhskv6ch1ht8saec4pi0a99ip.apps.googleusercontent.com';

List<AuthProvider> emplakeAuthProviders() => [
      EmailAuthProvider(),
      GoogleProvider(clientId: _googleWebClientId),
    ];

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void _goPlay(BuildContext context) {
    if (context.mounted) context.go('/play');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final firebaseReady = ref.watch(firebaseReadyProvider);
    final scheme = Theme.of(context).colorScheme;

    if (!firebaseReady) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LanguageRow(settings: settings),
                const SizedBox(height: 24),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: scheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(l10n.loginSubtitle),
                const SizedBox(height: 16),
                Text(
                  kTeamDisplay,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.firebaseMissing,
                  style: TextStyle(color: scheme.error),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).continueAsGuest();
                    _goPlay(context);
                  },
                  icon: const Icon(Icons.person_outline),
                  label: Text(l10n.continueAsGuest),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SignInScreen(
      providers: emplakeAuthProviders(),
      showAuthActionSwitch: true,
      showPasswordVisibilityToggle: true,
      headerMaxExtent: 220,
      headerBuilder: (context, constraints, shrinkOffset) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LanguageRow(settings: settings),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(l10n.loginSubtitle),
              const SizedBox(height: 8),
              Text(
                kTeamDisplay,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      },
      footerBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).continueAsGuest();
              _goPlay(context);
            },
            icon: const Icon(Icons.person_outline),
            label: Text(l10n.continueAsGuest),
          ),
        );
      },
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) => _goPlay(context)),
        AuthStateChangeAction<UserCreated>((context, state) => _goPlay(context)),
      ],
    );
  }
}

class _LanguageRow extends ConsumerWidget {
  const _LanguageRow({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.language, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            ChoiceChip(
              label: const Text('🇧🇷 PT'),
              selected: settings.locale.languageCode == 'pt',
              onSelected: (_) => ref
                  .read(settingsProvider.notifier)
                  .setLocale(const Locale('pt')),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('🇺🇸 EN'),
              selected: settings.locale.languageCode == 'en',
              onSelected: (_) => ref
                  .read(settingsProvider.notifier)
                  .setLocale(const Locale('en')),
            ),
          ],
        ),
      ],
    );
  }
}
