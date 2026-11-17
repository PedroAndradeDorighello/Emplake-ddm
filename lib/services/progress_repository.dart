import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  throw UnimplementedError('override in main');
});

bool _isLocalOnlyUid(String uid) =>
    uid == 'guest_local' || uid.startsWith('guest_');

abstract class ProgressRepository {
  Future<UserProgress> load(String uid);
  Future<void> save(String uid, UserProgress progress);
  Future<Map<String, dynamic>?> readProfile(String uid);
  Future<void> mergeProfile(String uid, Map<String, dynamic> fields);
}

class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  String _key(String uid) => 'progress_$uid';

  @override
  Future<UserProgress> load(String uid) async {
    final raw = _prefs.getString(_key(uid));
    if (raw == null) return const UserProgress();
    return UserProgress.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(String uid, UserProgress progress) async {
    await _prefs.setString(_key(uid), jsonEncode(progress.toMap()));
  }

  @override
  Future<Map<String, dynamic>?> readProfile(String uid) async => null;

  @override
  Future<void> mergeProfile(String uid, Map<String, dynamic> fields) async {}
}

class FirestoreProgressRepository implements ProgressRepository {
  FirestoreProgressRepository(this._db, this._fallback);

  final FirebaseFirestore _db;
  final ProgressRepository _fallback;

  static const _cloudTimeout = Duration(seconds: 2);

  @override
  Future<UserProgress> load(String uid) async {
    // Convidado offline: só SharedPreferences (Firestore demora / falha sem auth).
    if (_isLocalOnlyUid(uid)) return _fallback.load(uid);
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_cloudTimeout);
      final remote = UserProgress.fromMap(snap.data());
      await _fallback.save(uid, remote);
      return remote;
    } catch (_) {
      return _fallback.load(uid);
    }
  }

  @override
  Future<void> save(String uid, UserProgress progress) async {
    await _fallback.save(uid, progress);
    if (_isLocalOnlyUid(uid)) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .set(progress.toMap(), SetOptions(merge: true))
          .timeout(_cloudTimeout);
    } catch (_) {
      // offline / sem permissão — local já salvo
    }
  }

  @override
  Future<Map<String, dynamic>?> readProfile(String uid) async {
    if (_isLocalOnlyUid(uid)) return null;
    try {
      final snap =
          await _db.collection('users').doc(uid).get().timeout(_cloudTimeout);
      return snap.data();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> mergeProfile(String uid, Map<String, dynamic> fields) async {
    if (_isLocalOnlyUid(uid)) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .set(fields, SetOptions(merge: true))
          .timeout(_cloudTimeout);
    } catch (_) {}
  }
}
