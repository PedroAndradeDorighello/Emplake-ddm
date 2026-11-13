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
    final settings = ref.watch(settingsProvider);
    final firebaseReady = ref.watch(firebaseReadyProvider);
    final scheme = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.18),
              scheme.surface,
              scheme.tertiary.withValues(alpha: 0.12),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 880 : 440),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: _BrandPane()),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _AuthPane(
                              settings: settings,
                              firebaseReady: firebaseReady,
                              onGuest: () {
                                ref.read(authProvider.notifier).continueAsGuest();
                                _goPlay(context);
                              },
                              onSignedIn: () => _goPlay(context),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          const _BrandPane(),
                          const SizedBox(height: 24),
                          _AuthPane(
                            settings: settings,
                            firebaseReady: firebaseReady,
                            onGuest: () {
                              ref.read(authProvider.notifier).continueAsGuest();
                              _goPlay(context);
                            },
                            onSignedIn: () => _goPlay(context),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPane extends StatelessWidget {
  const _BrandPane();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(l10n.loginSubtitle),
        const SizedBox(height: 24),
        Text(
          kTeamDisplay,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _AuthPane extends ConsumerWidget {
  const _AuthPane({
    required this.settings,
    required this.firebaseReady,
    required this.onGuest,
    required this.onSignedIn,
  });

  final SettingsState settings;
  final bool firebaseReady;
  final VoidCallback onGuest;
  final VoidCallback onSignedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        const SizedBox(height: 20),
        if (!firebaseReady) ...[
          Text(
            l10n.firebaseMissing,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onGuest,
            icon: const Icon(Icons.person_outline),
            label: Text(l10n.continueAsGuest),
          ),
        ] else
          FirebaseUIActions(
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) => onSignedIn()),
              AuthStateChangeAction<UserCreated>((context, state) => onSignedIn()),
            ],
            child: LoginView(
              action: AuthAction.signIn,
              providers: emplakeAuthProviders(),
              showTitle: false,
              showAuthActionSwitch: true,
              showPasswordVisibilityToggle: true,
              footerBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: OutlinedButton.icon(
                    onPressed: onGuest,
                    icon: const Icon(Icons.person_outline),
                    label: Text(l10n.continueAsGuest),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
