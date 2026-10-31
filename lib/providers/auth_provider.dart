import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthSession {
  const AuthSession({
    required this.uid,
    this.email,
    this.isGuest = false,
    this.firebaseReady = false,
  });

  final String uid;
  final String? email;
  final bool isGuest;
  final bool firebaseReady;
}

class AuthNotifier extends StateNotifier<AuthSession?> {
  AuthNotifier({required this.firebaseReady}) : super(null) {
    if (firebaseReady) {
      _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          state = AuthSession(
            uid: user.uid,
            email: user.email,
            firebaseReady: true,
          );
        } else if (state?.isGuest != true) {
          state = null;
        }
      });
    }
  }

  final bool firebaseReady;
  dynamic _sub;

  void continueAsGuest() {
    state = AuthSession(
      uid: 'guest_local',
      isGuest: true,
      firebaseReady: firebaseReady,
    );
  }

  Future<void> signInEmail(String email, String password) async {
    if (!firebaseReady) {
      continueAsGuest();
      return;
    }
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _applyCurrentUser();
  }

  Future<void> registerEmail(String email, String password) async {
    if (!firebaseReady) {
      continueAsGuest();
      return;
    }
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _applyCurrentUser();
  }

  Future<void> signInAnonymously() async {
    if (!firebaseReady) {
      continueAsGuest();
      return;
    }
    await FirebaseAuth.instance.signInAnonymously();
    _applyCurrentUser();
  }

  void adoptCurrentUser() => _applyCurrentUser();

  void _applyCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    state = AuthSession(
      uid: user.uid,
      email: user.email,
      firebaseReady: true,
    );
  }

  Future<void> signOut() async {
    if (firebaseReady) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    state = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final firebaseReadyProvider = Provider<bool>((ref) => false);

final authProvider = StateNotifierProvider<AuthNotifier, AuthSession?>((ref) {
  return AuthNotifier(firebaseReady: ref.watch(firebaseReadyProvider));
});
