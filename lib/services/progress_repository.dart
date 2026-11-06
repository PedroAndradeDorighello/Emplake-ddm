import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  throw UnimplementedError('override in main');
});

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

  @override
  Future<UserProgress> load(String uid) async {
    try {
      final snap = await _db.collection('users').doc(uid).get();
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
    try {
      await _db.collection('users').doc(uid).set(progress.toMap(), SetOptions(merge: true));
    } catch (_) {
      // offline / sem config — local já salvo
    }
  }

  @override
  Future<Map<String, dynamic>?> readProfile(String uid) async {
    try {
      final snap = await _db.collection('users').doc(uid).get();
      return snap.data();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> mergeProfile(String uid, Map<String, dynamic> fields) async {
    try {
      await _db.collection('users').doc(uid).set(fields, SetOptions(merge: true));
    } catch (_) {}
  }
}
