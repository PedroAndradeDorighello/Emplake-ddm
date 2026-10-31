import 'package:firebase_auth/firebase_auth.dart';
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _emailAuth({required bool register}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = ref.read(authProvider.notifier);
      if (register) {
        await auth.registerEmail(_email.text.trim(), _password.text);
      } else {
        await auth.signInEmail(_email.text.trim(), _password.text);
      }
      if (mounted) context.go('/play');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? e.code);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                        children: [
                          Expanded(child: _BrandPane(l10n: l10n)),
                          const SizedBox(width: 24),
                          Expanded(child: _form(l10n, settings, firebaseReady)),
                        ],
                      )
                    : ListView(
                        children: [
                          _BrandPane(l10n: l10n),
                          const SizedBox(height: 24),
                          _form(l10n, settings, firebaseReady),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(
    AppLocalizations l10n,
    SettingsState settings,
    bool firebaseReady,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.language, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            _FlagButton(
              label: '🇧🇷 PT',
              selected: settings.locale.languageCode == 'pt',
              onTap: () => ref
                  .read(settingsProvider.notifier)
                  .setLocale(const Locale('pt')),
            ),
            const SizedBox(width: 8),
            _FlagButton(
              label: '🇺🇸 EN',
              selected: settings.locale.languageCode == 'en',
              onTap: () => ref
                  .read(settingsProvider.notifier)
                  .setLocale(const Locale('en')),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (!firebaseReady)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.firebaseMissing,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        TextField(
          controller: _email,
          decoration: InputDecoration(
            labelText: l10n.email,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.password,
            border: const OutlineInputBorder(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : () => _emailAuth(register: false),
          child: Text(l10n.signInEmail),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _busy ? null : () => _emailAuth(register: true),
          child: const Text('Sign up / Registrar'),
        ),
        const SizedBox(height: 8),
        if (firebaseReady)
          OAuthProviderButton(
            provider: GoogleProvider(clientId: _googleWebClientId),
          )
        else
          OutlinedButton(
            onPressed: () {
              ref.read(authProvider.notifier).continueAsGuest();
              context.go('/play');
            },
            child: Text(l10n.signInGoogle),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  try {
                    await ref.read(authProvider.notifier).signInAnonymously();
                    if (mounted) context.go('/play');
                  } catch (e) {
                    setState(() => _error = e.toString());
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          child: Text(l10n.continueAsGuest),
        ),
      ],
    );
  }
}

class _BrandPane extends StatelessWidget {
  const _BrandPane({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary),
        ),
        const SizedBox(height: 8),
        Text(l10n.loginSubtitle),
        const SizedBox(height: 24),
        Text(
          kTeamDisplay,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _FlagButton extends StatelessWidget {
  const _FlagButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
