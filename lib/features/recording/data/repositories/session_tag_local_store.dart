import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
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

  Future<Map<String, String>> _readAll() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final result = <String, String>{};
      decoded.forEach((key, value) {
        if (key is! String || value is! String) return;
        final normalized = SessionTagCatalog.normalize(value);
        if (normalized != null) {
          result[key] = normalized;
        }
      });
      return result;
    } catch (_) {
      await _storage.delete(key: _key);
      return {};
    }
  }

  Future<void> _writeAll(Map<String, String> tags) {
    return _storage.write(key: _key, value: jsonEncode(tags));
  }

  Future<String?> getTag(String sessionId) async {
    final all = await _readAll();
    return all[sessionId];
  }

  Future<void> setTag(String sessionId, String? tag) async {
    final all = await _readAll();
    final normalized = SessionTagCatalog.normalize(tag);
    if (normalized == null) {
      all.remove(sessionId);
    } else {
      all[sessionId] = normalized;
    }
    await _writeAll(all);
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
