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

  static const String _storageKey = 'recording_session_tags_v1';

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
    final String? rawJson;
    try {
      rawJson = await _storage.read(key: _storageKey);
    } on PlatformException catch (e) {
      throw StorageException(
        'Impossible de lire "$_storageKey" depuis le stockage sécurisé',
        cause: e,
      );
    }

    if (rawJson == null || rawJson.isEmpty) return {};

    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException catch (e) {
      throw StorageException(
        'JSON invalide pour la clé "$_storageKey"',
        cause: e,
      );
    }

    if (decoded is! Map) {
      if (kDebugMode) {
        debugPrint(
          '[SessionTagLocalStore] "$_storageKey": attendu Map, '
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
    return _storage.write(key: _storageKey, value: jsonEncode(tags));
  }

  Future<String?> getTag(String sessionId) async {
    final allTags = await _readAll();
    return allTags[sessionId];
  }

  Future<void> setTag(String sessionId, String? tag) {
    return _runExclusive(() async {
      final allTags = await _readAll();
      final normalized = SessionTagCatalog.normalize(tag);
      if (normalized == null) {
        allTags.remove(sessionId);
      } else {
        allTags[sessionId] = normalized;
      }
      await _writeAll(allTags);
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
    final allTags = await _readAll();
    if (allTags.isEmpty) return sessions;
    return [
      for (final session in sessions)
        if (session.tag != null && session.tag!.trim().isNotEmpty)
          session
        else if (allTags.containsKey(session.id))
          session.copyWith(tag: allTags[session.id])
        else
          session,
    ];
  }
}
