import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/session_tags/session_tag_catalog.dart';

/// Local-first overlay for session tags.
///
/// TODO(api-sync): when the backend exposes an optional `tag` on the session
/// DTO, prefer the API value and retire this overlay (keep as cache/fallback).
@lazySingleton
class SessionTagLocalStore {
  SessionTagLocalStore(this._storage);

  static const String _key = 'recording_session_tags_v1';

  final FlutterSecureStorage _storage;

  Future<void> _lock = Future<void>.value();

  Future<R> _runExclusive<R>(Future<R> Function() action) async {
    final previous = _lock;
    final completer = Completer<void>();
    _lock = completer.future;
    await previous;
    try {
      return await action();
    } finally {
      completer.complete();
    }
  }

  Future<Map<String, String>> _readAll() async {
    final String? raw;
    try {
      raw = await _storage.read(key: _key);
    } on PlatformException catch (e) {
      throw StorageException(
        'Impossible de lire "$_key" depuis le stockage sécurisé',
        cause: e,
      );
    }

    if (raw == null || raw.isEmpty) return {};

    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      throw StorageException(
        'JSON invalide pour la clé "$_key"',
        cause: e,
      );
    }

    if (decoded is! Map) {
      if (kDebugMode) {
        debugPrint(
          '[SessionTagLocalStore] "$_key": attendu Map, '
          'reçu ${decoded.runtimeType}',
        );
      }
      return {};
    }

    final result = <String, String>{};
    decoded.forEach((key, value) {
      if (key is! String || value is! String) return;
      final normalized = SessionTagCatalog.normalize(value);
      if (normalized != null) {
        result[key] = normalized;
      }
    });
    return result;
  }

  Future<void> _writeAll(Map<String, String> tags) {
    return _storage.write(key: _key, value: jsonEncode(tags));
  }

  Future<String?> getTag(String sessionId) async {
    final all = await _readAll();
    return all[sessionId];
  }

  Future<void> setTag(String sessionId, String? tag) {
    return _runExclusive(() async {
      final all = await _readAll();
      final normalized = SessionTagCatalog.normalize(tag);
      if (normalized == null) {
        all.remove(sessionId);
      } else {
        all[sessionId] = normalized;
      }
      await _writeAll(all);
    });
  }

  Future<RecordingSession> merge(RecordingSession session) async {
    final overlay = await getTag(session.id);
    if (overlay == null || overlay.isEmpty) {
      return session;
    }
    if (session.tag == overlay) return session;
    // Prefer explicit session.tag when already set (local guest JSON).
    if (session.tag != null && session.tag!.trim().isNotEmpty) {
      return session;
    }
    return session.copyWith(tag: overlay);
  }

  Future<List<RecordingSession>> mergeAll(List<RecordingSession> sessions) async {
    final all = await _readAll();
    if (all.isEmpty) return sessions;
    return [
      for (final session in sessions)
        if (session.tag != null && session.tag!.trim().isNotEmpty)
          session
        else if (all.containsKey(session.id))
          session.copyWith(tag: all[session.id])
        else
          session,
    ];
  }
}
