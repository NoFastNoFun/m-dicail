import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/storage/secure_collection_store.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

/// In-memory [FlutterSecureStorage] used by all tests in this file.
class _MemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  /// Direct access for test assertions.
  String? rawValue(String key) => _store[key];
  void rawSet(String key, String value) => _store[key] = value;
}

/// Storage that throws [PlatformException] on every read.
class _FailingReadStorage extends _MemorySecureStorage {
  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(code: 'BadPaddingException', message: 'decrypt failed');
  }
}

/// Minimal model for tests.
class _Item {
  _Item(this.id, this.name);

  factory _Item.fromJson(Map<String, dynamic> json) =>
      _Item(json['id'] as String, json['name'] as String);

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _key = 'test_items_v1';

SecureCollectionStore<_Item> _buildStore(_MemorySecureStorage storage) {
  return SecureCollectionStore<_Item>(
    storage: storage,
    key: _key,
    fromJson: _Item.fromJson,
    toJson: (item) => item.toJson(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // R1 — Une erreur de lecture ne supprime JAMAIS les données
  // =========================================================================
  group('R1 – readAll safety', () {
    test('returns empty list when key does not exist', () async {
      final storage = _MemorySecureStorage();
      final store = _buildStore(storage);

      final result = await store.readAll();
      expect(result, isEmpty);
    });

    test('returns empty list when stored value is empty string', () async {
      final storage = _MemorySecureStorage()..rawSet(_key, '');
      final store = _buildStore(storage);

      final result = await store.readAll();
      expect(result, isEmpty);
    });

    test('returns items when JSON is valid', () async {
      final storage = _MemorySecureStorage()
        ..rawSet(_key, '[{"id":"1","name":"Alice"},{"id":"2","name":"Bob"}]');
      final store = _buildStore(storage);

      final result = await store.readAll();
      expect(result, hasLength(2));
      expect(result[0].id, '1');
      expect(result[1].name, 'Bob');
    });

    test('throws StorageException on invalid JSON – data is NOT deleted',
        () async {
      final storage = _MemorySecureStorage()..rawSet(_key, '{not valid json!!');
      final store = _buildStore(storage);

      expect(() => store.readAll(), throwsA(isA<StorageException>()));

      // The raw data must still be there.
      expect(storage.rawValue(_key), '{not valid json!!');
    });

    test('returns empty list when JSON decodes to non-List – data preserved',
        () async {
      final storage = _MemorySecureStorage()
        ..rawSet(_key, '{"wrong":"type"}');
      final store = _buildStore(storage);

      final result = await store.readAll();
      expect(result, isEmpty);

      // Raw data is preserved.
      expect(storage.rawValue(_key), '{"wrong":"type"}');
    });

    test(
        'throws StorageException on PlatformException – data is NOT deleted',
        () async {
      final storage = _FailingReadStorage()..rawSet(_key, '[{"id":"1","name":"A"}]');
      final store = _buildStore(storage);

      expect(() => store.readAll(), throwsA(isA<StorageException>()));

      // The raw data must still be there (FailingReadStorage inherits the map).
      expect(storage.rawValue(_key), '[{"id":"1","name":"A"}]');
    });
  });

  // =========================================================================
  // R13 — Deux mutations concurrentes conservent les deux résultats
  // =========================================================================
  group('R13 – concurrent mutation safety', () {
    test('two concurrent mutate() calls preserve both changes', () async {
      final storage = _MemorySecureStorage();
      final store = _buildStore(storage);

      // Seed with one item.
      await store.mutate((_) => [_Item('seed', 'Seed')]);

      // Launch two concurrent saves.
      final futureA = store.mutate((current) => [
            ...current,
            _Item('a', 'Alice'),
          ]);
      final futureB = store.mutate((current) => [
            ...current,
            _Item('b', 'Bob'),
          ]);

      await Future.wait([futureA, futureB]);

      final result = await store.readAll();
      final ids = result.map((i) => i.id).toSet();
      expect(ids, containsAll(['seed', 'a', 'b']),
          reason: 'Both concurrent saves must be preserved');
    });

    test('concurrent mutate + clear: clear wins when ordered last', () async {
      final storage = _MemorySecureStorage();
      final store = _buildStore(storage);

      await store.mutate((_) => [_Item('1', 'X')]);

      // mutate first, clear second — both queued immediately.
      final futureMutate = store.mutate((current) => [
            ...current,
            _Item('2', 'Y'),
          ]);
      final futureClear = store.clear();

      await Future.wait([futureMutate, futureClear]);

      final result = await store.readAll();
      expect(result, isEmpty, reason: 'clear() ran after mutate()');
    });

    test('concurrent delete + save preserve correct result', () async {
      final storage = _MemorySecureStorage();
      final store = _buildStore(storage);

      await store.mutate((_) => [_Item('1', 'Alice'), _Item('2', 'Bob')]);

      // Delete item 1 and save item 3 concurrently.
      final futureDelete = store.mutate(
        (current) => [for (final i in current) if (i.id != '1') i],
      );
      final futureSave = store.mutate((current) => [
            ...current,
            _Item('3', 'Charlie'),
          ]);

      await Future.wait([futureDelete, futureSave]);

      final result = await store.readAll();
      final ids = result.map((i) => i.id).toSet();
      expect(ids.contains('1'), isFalse, reason: 'Item 1 was deleted');
      expect(ids.containsAll(['2', '3']), isTrue,
          reason: 'Item 2 kept, item 3 added');
    });
  });

  // =========================================================================
  // replaceAll
  // =========================================================================
  group('replaceAll', () {
    test('replaces entire collection', () async {
      final storage = _MemorySecureStorage();
      final store = _buildStore(storage);

      await store.mutate((_) => [_Item('old', 'OldItem')]);
      await store.replaceAll([_Item('new1', 'A'), _Item('new2', 'B')]);

      final result = await store.readAll();
      expect(result, hasLength(2));
      expect(result[0].id, 'new1');
    });
  });

  // =========================================================================
  // clear
  // =========================================================================
  group('clear', () {
    test('removes all data', () async {
      final storage = _MemorySecureStorage();
      final store = _buildStore(storage);

      await store.mutate((_) => [_Item('1', 'X')]);
      await store.clear();

      final result = await store.readAll();
      expect(result, isEmpty);
      expect(storage.rawValue(_key), isNull);
    });
  });
}
