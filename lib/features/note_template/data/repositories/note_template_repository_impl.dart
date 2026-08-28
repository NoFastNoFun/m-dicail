import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/note_template/data/datasources/asset_note_template_data_source.dart';
import 'package:medicail/features/note_template/data/models/note_template_model.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart';

@LazySingleton(as: NoteTemplateRepository)
class NoteTemplateRepositoryImpl implements NoteTemplateRepository {
  NoteTemplateRepositoryImpl(
    this._assetDataSource,
    this._storage,
  );

  static const String _userVariantsKey = 'note_templates_user_v1';

  final AssetNoteTemplateDataSource _assetDataSource;
  final FlutterSecureStorage _storage;

  @override
  Future<List<NoteTemplate>> getAll() async {
    final builtIn = await getBuiltInTemplates();
    final variants = await getUserVariants();
    return [...builtIn, ...variants];
  }

  @override
  Future<List<NoteTemplate>> getBuiltInTemplates() {
    return _assetDataSource.loadBuiltInTemplates();
  }

  @override
  Future<List<NoteTemplate>> getUserVariants() async {
    final variants = (await _readUserVariants()).toList();
    variants.sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return variants;
  }

  @override
  Future<NoteTemplate?> getById(String id) async {
    if (id.isEmpty) {
      return null;
    }

    final builtIn = await getBuiltInTemplates();
    for (final template in builtIn) {
      if (template.id == id) {
        return template;
      }
    }

    try {
      final variants = await getUserVariants();
      for (final template in variants) {
        if (template.id == id) {
          return template;
        }
      }
    } catch (_) {
      // Built-in templates remain resolvable when variant storage fails.
    }

    return null;
  }

  @override
  Future<NoteTemplate> saveVariant(NoteTemplate template) async {
    if (template.source != NoteTemplateSource.userVariant) {
      throw StateError('Only user variants can be saved.');
    }

    final now = DateTime.now();
    final saved = template.copyWith(updatedAt: now);
    final variants = await _readUserVariants();
    final nextVariants = <NoteTemplate>[
      for (final current in variants)
        if (current.id != saved.id) current,
      saved,
    ];

    await _writeUserVariants(nextVariants);
    return saved;
  }

  @override
  Future<NoteTemplate> duplicateAsVariant({
    required String parentTemplateId,
    required String name,
  }) async {
    final parent = await getById(parentTemplateId);
    if (parent == null) {
      throw StateError('Parent template not found.');
    }

    final variantId =
        'variant_${DateTime.now().toUtc().microsecondsSinceEpoch}';
    final variant = NoteTemplateModel(
      id: variantId,
      pathologyKey: parent.pathologyKey,
      pathologyId: parent.pathologyId,
      name: name.trim(),
      sections: parent.sections,
      source: NoteTemplateSource.userVariant,
      parentTemplateId: parent.id,
      updatedAt: DateTime.now(),
    );

    return saveVariant(variant);
  }

  @override
  Future<void> deleteVariant(String id) async {
    final existing = await getById(id);
    if (existing == null) {
      return;
    }
    if (existing.source != NoteTemplateSource.userVariant) {
      throw StateError('Built-in templates cannot be deleted.');
    }

    final variants = await _readUserVariants();
    final nextVariants = <NoteTemplate>[
      for (final current in variants)
        if (current.id != id) current,
    ];
    await _writeUserVariants(nextVariants);
  }

  Future<List<NoteTemplate>> _readUserVariants() async {
    try {
      final raw = await _storage.read(key: _userVariantsKey);
      if (raw == null || raw.isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return [
        for (final item in decoded)
          if (item is Map)
            NoteTemplateModel.fromJson(Map<String, dynamic>.from(item)),
      ];
    } catch (_) {
      try {
        await _storage.delete(key: _userVariantsKey);
      } catch (_) {
        // Best effort cleanup when local variants are corrupted.
      }
      return const [];
    }
  }

  Future<void> _writeUserVariants(List<NoteTemplate> variants) {
    final encoded = jsonEncode(
      variants
          .map(NoteTemplateModel.fromEntity)
          .map((template) => template.toJson())
          .toList(),
    );
    return _storage.write(key: _userVariantsKey, value: encoded);
  }
}
