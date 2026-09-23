import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medicail/core/error/exceptions.dart';

/// Generic helper that persists a JSON-encoded `List<T>` in
/// [FlutterSecureStorage] with two guarantees the raw API does not provide:
///
/// **R1 – Safe reads**: a read error (keystore corruption, invalid JSON) never
/// deletes the stored data.  Instead a [StorageException] is thrown so the
/// caller can decide how to recover.
///
/// **R13 – Serialised mutations**: every read→transform→write cycle runs inside
/// a per-key async lock so two concurrent [mutate] calls cannot overwrite each
/// other's changes.
class SecureCollectionStore<T> {
  SecureCollectionStore({
    required FlutterSecureStorage storage,
    required String key,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T item) toJson,
  })  : _storage = storage,
        _storageKey = key,
        _fromJson = fromJson,
        _toJson = toJson;

  final FlutterSecureStorage _storage;
  final String _storageKey;
  final T Function(Map<String, dynamic> json) _fromJson;
  final Map<String, dynamic> Function(T item) _toJson;

  // ---------------------------------------------------------------------------
  // Async lock (single-isolate safe)
  // ---------------------------------------------------------------------------
  Future<void> _mutationLock = Future<void>.value();

  Future<R> _runExclusive<R>(Future<R> Function() action) async {
    final previousLock = _mutationLock;
    final completer = Completer<void>();
    _mutationLock = completer.future;
    await previousLock;
    try {
      return await action();
    } finally {
      completer.complete();
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Reads the full collection.
  ///
  /// * Key absent / empty → empty list (not an error).
  /// * Stored value is not a JSON list → empty list + debug warning.
  /// * JSON syntax error or keystore failure → [StorageException] (data is
  ///   **never** deleted).
  Future<List<T>> readAll() async {
    final String? rawJson;
    try {
      rawJson = await _storage.read(key: _storageKey);
    } on PlatformException catch (e) {
      throw StorageException(
        'Impossible de lire "$_storageKey" depuis le stockage sécurisé',
        cause: e,
      );
    }

    if (rawJson == null || rawJson.isEmpty) return const [];

    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException catch (e) {
      throw StorageException(
        'JSON invalide pour la clé "$_storageKey"',
        cause: e,
      );
    }

    if (decoded is! List) {
      if (kDebugMode) {
        debugPrint(
          '[SecureCollectionStore] "$_storageKey": attendu List, '
          'reçu ${decoded.runtimeType}',
        );
      }
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((json) => Map<String, dynamic>.from(json))
        .map(_fromJson)
        .toList();
  }

  /// Atomically reads the current list, applies [transform], and writes the
  /// result back.  Returns the transformed list.
  ///
  /// The entire read→transform→write cycle is serialised: two concurrent
  /// [mutate] calls will run one after the other, never in parallel.
  Future<List<T>> mutate(List<T> Function(List<T> current) transform) {
    return _runExclusive(() async {
      final currentItems = await readAll();
      final nextItems = transform(currentItems);
      await _writeItems(nextItems);
      return nextItems;
    });
  }

  /// Replaces the entire collection atomically (used e.g. for cache refresh).
  Future<void> replaceAll(List<T> items) {
    return _runExclusive(() => _writeItems(items));
  }

  /// Deletes the storage key.  Also serialised so it cannot race with a
  /// concurrent [mutate].
  Future<void> clear() {
    return _runExclusive(() => _storage.delete(key: _storageKey));
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------
  Future<void> _writeItems(List<T> items) {
    final encoded = jsonEncode(items.map(_toJson).toList());
    return _storage.write(key: _storageKey, value: encoded);
  }
}
